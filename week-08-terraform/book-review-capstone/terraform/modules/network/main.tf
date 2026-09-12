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

  nat_gateway_count = var.single_nat_gateway ? 1 : 2
}

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-vpc"
  })
}

# ---------------------------------------------------------------------------
# Subnets — Web Tier (public), App Tier (private), DB Tier (private)
# ---------------------------------------------------------------------------

resource "aws_subnet" "web" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.web_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-subnet-web-${local.az_suffix[count.index]}"
    Tier = "web"
  })
}

resource "aws_subnet" "app" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.app_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-subnet-app-${local.az_suffix[count.index]}"
    Tier = "app"
  })
}

resource "aws_subnet" "db" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.db_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-subnet-db-${local.az_suffix[count.index]}"
    Tier = "db"
  })
}

# ---------------------------------------------------------------------------
# Internet Gateway — Web Tier egress/ingress
# ---------------------------------------------------------------------------

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

# ---------------------------------------------------------------------------
# NAT Gateway(s) — controlled egress for the App Tier only.
# Default: a single NAT Gateway in Web-A shared by both App subnets
# (cost optimization). Set single_nat_gateway = false for one NAT per AZ.
# ---------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count  = local.nat_gateway_count
  domain = "vpc"

  depends_on = [aws_internet_gateway.this]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-eip-nat-${local.az_suffix[count.index]}"
  })
}

resource "aws_nat_gateway" "this" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.web[count.index].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-nat-${local.az_suffix[count.index]}"
  })
}

# ---------------------------------------------------------------------------
# Route Tables
# ---------------------------------------------------------------------------

# 1) Public route table — Web Tier subnets route to the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-rtb-public"
  })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "web" {
  count          = 2
  subnet_id      = aws_subnet.web[count.index].id
  route_table_id = aws_route_table.public.id
}

# 2) Private App route table(s) — egress-only via NAT Gateway, no inbound
#    route from the internet. When a single NAT Gateway is used, both App
#    subnets share one route table pointing at the same NAT Gateway.
resource "aws_route_table" "private_app" {
  count  = local.nat_gateway_count
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-rtb-private-app-${local.az_suffix[count.index]}"
  })
}

resource "aws_route" "app_nat_access" {
  count                  = local.nat_gateway_count
  route_table_id         = aws_route_table.private_app[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "app" {
  count          = 2
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private_app[var.single_nat_gateway ? 0 : count.index].id
}

# 3) Private DB route table — no internet/NAT route at all. Only the
#    implicit VPC-local route exists, so the Database Tier cannot reach
#    or be reached from the internet.
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-rtb-private-db"
  })
}

resource "aws_route_table_association" "db" {
  count          = 2
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.private_db.id
}
