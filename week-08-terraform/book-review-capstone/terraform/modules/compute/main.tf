locals {
  az_suffix = ["a", "b"]

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  # ---------------------------------------------------------------------------
  # Bootstrap-only user-data.
  #
  # Scope is intentionally limited to OS-level provisioning: runtime install
  # (Node.js LTS via NodeSource), PM2 (process manager), nginx (Web Tier
  # only), and a git clone of the application repository. It does NOT run
  # `npm install`/build/start, define PM2 process files, or write any
  # environment variables (DB connection strings, API base URLs, ports).
  #
  # Rationale: per the required engineering sequence, "Application
  # Deployment" is a separate phase from "Compute". Guessing the repo's
  # actual entry points, build commands, directory names (frontend/backend
  # split), or .env variable names here would violate the project rule
  # against assuming application details without inspecting package.json /
  # the repo structure first. It would also risk embedding the RDS master
  # password into EC2 user-data (a plaintext-secret-at-rest exposure) before
  # a safer injection mechanism (e.g. SSM Parameter Store / Secrets Manager
  # pulled at boot) is deliberately chosen. Both are addressed in the
  # Application Deployment phase.
  # ---------------------------------------------------------------------------

  bootstrap_common = <<-EOT
    #!/bin/bash
    set -euxo pipefail

    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg git

    # Node.js LTS (20.x) via NodeSource
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs

    # PM2 process manager, run globally
    npm install -g pm2

    # Clone the application repository for the upcoming Application
    # Deployment phase. Left uninitialized (no install/build/start) here.
    mkdir -p /opt/app
    git clone "${var.repo_url}" /opt/app/book-review-app || true
    chown -R ubuntu:ubuntu /opt/app
  EOT

  web_user_data = <<-EOT
    ${local.bootstrap_common}

    # Web Tier only: nginx as the front door for the public ALB target.
    # Reverse-proxy configuration to the Next.js process is deferred to the
    # Application Deployment phase (requires the frontend's actual listen
    # port from the repo).
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
  EOT

  app_user_data = <<-EOT
    ${local.bootstrap_common}
  EOT
}

# ---------------------------------------------------------------------------
# Ubuntu 22.04 LTS (Jammy) AMI — latest patch, Canonical-owned, HVM/EBS.
# Shared by both the Web and Application Tier instances.
# ---------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ===========================================================================
# Web Tier — public subnets, registered with the public ALB target group.
# associate_public_ip_address = true: these instances must be reachable by
# the public ALB's health checks/forwarded traffic and need outbound
# internet access for package installs without relying on the NAT Gateway.
# ===========================================================================

resource "aws_instance" "web" {
  count = 2

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.web_instance_type
  subnet_id                   = var.public_web_subnet_ids[count.index]
  vpc_security_group_ids      = [var.web_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data                   = local.web_user_data

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
  }

  metadata_options {
    http_tokens = "required" # enforce IMDSv2
  }

  tags = merge(local.common_tags, {
    Name             = "${var.project_name}-web-${local.az_suffix[count.index]}"
    Tier             = "web"
    Role             = "web-server"
    AvailabilityZone = var.availability_zones[count.index]
  })
}

# ===========================================================================
# Application Tier — private subnets, registered with the internal ALB
# target group. associate_public_ip_address = false: these instances have
# no public IP; outbound internet access (for package installs) is via the
# NAT Gateway only, per the network module's private App route table.
# ===========================================================================

resource "aws_instance" "app" {
  count = 2

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.app_instance_type
  subnet_id                   = var.private_app_subnet_ids[count.index]
  vpc_security_group_ids      = [var.app_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = false
  user_data                   = local.app_user_data

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
  }

  metadata_options {
    http_tokens = "required" # enforce IMDSv2
  }

  tags = merge(local.common_tags, {
    Name             = "${var.project_name}-app-${local.az_suffix[count.index]}"
    Tier             = "app"
    Role             = "app-server"
    AvailabilityZone = var.availability_zones[count.index]
  })
}

# ---------------------------------------------------------------------------
# Target group attachments — register each tier's instances with its
# respective ALB target group. Implicit dependency on both the instances
# and the target groups; no explicit depends_on needed.
# ---------------------------------------------------------------------------

resource "aws_lb_target_group_attachment" "web" {
  count = 2

  target_group_arn = var.public_target_group_arn
  target_id        = aws_instance.web[count.index].id
  port             = var.public_alb_port
}

resource "aws_lb_target_group_attachment" "app" {
  count = 2

  target_group_arn = var.internal_target_group_arn
  target_id        = aws_instance.app[count.index].id
  port             = var.internal_alb_port
}
