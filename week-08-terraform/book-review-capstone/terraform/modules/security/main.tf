locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# ---------------------------------------------------------------------------
# NOTE ON RULE STYLE
#
# Rules are implemented as standalone `aws_vpc_security_group_ingress_rule`
# / `aws_vpc_security_group_egress_rule` resources rather than inline
# ingress {}/egress {} blocks on aws_security_group, and rather than the
# older `aws_security_group_rule` resource. This is the AWS provider's
# current documented best practice: inline blocks and aws_security_group_rule
# both struggle with multiple CIDRs and lack stable per-rule IDs/tags, which
# causes perpetual diffs and rule-overwrite bugs. The newer resources give
# each rule its own ID and description, and each SG-to-SG reference is
# expressed explicitly via `referenced_security_group_id`.
# ---------------------------------------------------------------------------

# ===========================================================================
# 1) Public ALB SG — internet-facing entry point.
#    Accepts HTTP from the internet, forwards only to the Web Tier.
# ===========================================================================

resource "aws_security_group" "public_alb" {
  name        = "${var.project_name}-sg-public-alb"
  description = "Public ALB: accepts HTTP from the internet and forwards to the Web Tier only."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-sg-public-alb"
    Tier = "public-alb"
  })
}

resource "aws_vpc_security_group_ingress_rule" "public_alb_http_from_internet" {
  security_group_id = aws_security_group.public_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "Allow HTTP from the internet to the public ALB."
}

resource "aws_vpc_security_group_egress_rule" "public_alb_to_web" {
  security_group_id            = aws_security_group.public_alb.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "Forward HTTP traffic from the public ALB to the Web Tier only."
}

# ===========================================================================
# 2) Web Tier SG — public ALB targets (Load Balancer / web servers).
#    Accepts HTTP only from the public ALB and SSH only from the admin IP.
#    Forwards application traffic to the internal ALB; reaches the internet
#    (via NAT Gateway) for package installs/updates only.
# ===========================================================================

resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg-web"
  description = "Web Tier: accepts HTTP from the public ALB and admin SSH, forwards to the internal ALB."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-sg-web"
    Tier = "web"
  })
}

resource "aws_vpc_security_group_ingress_rule" "web_http_from_public_alb" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.public_alb.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  description                  = "Allow HTTP from the public ALB only."
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh_from_admin" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = var.my_ip
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  description       = "Allow SSH admin access from the approved administrator IP only."
}

resource "aws_vpc_security_group_egress_rule" "web_to_internal_alb" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.internal_alb.id
  ip_protocol                  = "tcp"
  from_port                    = 3001
  to_port                      = 3001
  description                  = "Forward application traffic from the Web Tier to the internal ALB."
}

resource "aws_vpc_security_group_egress_rule" "web_ssh_to_app" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow SSH from Web Tier to Application Tier for deployment/jump access."
}

resource "aws_vpc_security_group_egress_rule" "web_http_to_internet" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "Allow outbound HTTP (via NAT Gateway) for OS/package updates."
}

resource "aws_vpc_security_group_egress_rule" "web_https_to_internet" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Allow outbound HTTPS (via NAT Gateway) for OS/package updates."
}

# ===========================================================================
# 3) Internal ALB SG — sits between Web Tier and Application Tier.
#    Accepts application traffic (3001) only from the Web Tier, forwards
#    only to the Application Tier. Never exposed to the internet.
# ===========================================================================

resource "aws_security_group" "internal_alb" {
  name        = "${var.project_name}-sg-internal-alb"
  description = "Internal ALB: accepts port 3001 from the Web Tier only, forwards to the Application Tier."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-sg-internal-alb"
    Tier = "internal-alb"
  })
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_web" {
  security_group_id            = aws_security_group.internal_alb.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 3001
  to_port                      = 3001
  description                  = "Allow application traffic (3001) from the Web Tier only."
}

resource "aws_vpc_security_group_egress_rule" "internal_alb_to_app" {
  security_group_id            = aws_security_group.internal_alb.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 3001
  to_port                      = 3001
  description                  = "Forward application traffic (3001) from the internal ALB to the Application Tier."
}

# ===========================================================================
# 4) Application Tier SG — private app servers running the Node/Express API.
#    Accepts port 3001 only from the internal ALB, SSH only from the Web
#    Tier (jump-host pattern). Queries the DB Tier; reaches the internet
#    (via NAT Gateway) for package installs/updates only.
# ===========================================================================

resource "aws_security_group" "app" {
  name        = "${var.project_name}-sg-app"
  description = "Application Tier: accepts port 3001 from the internal ALB and SSH from the Web Tier only."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-sg-app"
    Tier = "app"
  })
}

resource "aws_vpc_security_group_ingress_rule" "app_from_internal_alb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.internal_alb.id
  ip_protocol                  = "tcp"
  from_port                    = 3001
  to_port                      = 3001
  description                  = "Allow application traffic (3001) from the internal ALB only."
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh_from_web" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  description                  = "Allow SSH from the Web Tier only (jump-host pattern for admin access to app servers)."
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  description                  = "Allow MySQL queries from the Application Tier to the Database Tier only."
}

resource "aws_vpc_security_group_egress_rule" "app_http_to_internet" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "Allow outbound HTTP (via NAT Gateway) for OS/package updates."
}

resource "aws_vpc_security_group_egress_rule" "app_https_to_internet" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Allow outbound HTTPS (via NAT Gateway) for OS/package updates."
}

# ===========================================================================
# 5) Database Tier SG — RDS MySQL (Multi-AZ + read replica).
#    Accepts MySQL (3306) only from the Application Tier and, for
#    replication/standby sync, from other members of this same SG. No
#    outbound rules — RDS does not need to initiate outbound connections,
#    and the DB Tier route table has no internet/NAT route in any case.
# ===========================================================================

resource "aws_security_group" "db" {
  name        = "${var.project_name}-sg-db"
  description = "Database Tier: accepts MySQL (3306) from the Application Tier only. No internet exposure."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-sg-db"
    Tier = "db"
  })
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  description                  = "Allow MySQL traffic from the Application Tier only."
}

resource "aws_vpc_security_group_ingress_rule" "db_self_replication" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  description                  = "Allow MySQL traffic within this SG for Multi-AZ standby sync and read-replica replication."
}

# Intentionally no egress rules on the db SG: default AWS behavior with no
# egress rules is deny-all outbound, which is correct for an RDS instance
# that never needs to initiate outbound connections.
