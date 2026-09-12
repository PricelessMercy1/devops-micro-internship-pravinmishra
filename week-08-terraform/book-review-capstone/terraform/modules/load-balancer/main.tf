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

# ===========================================================================
# 1) Public ALB — internet-facing entry point for the Web Tier.
#    Lives in the two public Web Tier subnets, protected by public-alb-sg
#    (HTTP from the internet only, forwards to the Web Tier only).
#    No instances are registered yet — that happens in the Compute phase.
# ===========================================================================

resource "aws_lb" "public" {
  name               = var.public_alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_alb_sg_id]
  subnets            = var.public_alb_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = true

  tags = merge(local.common_tags, {
    Name = var.public_alb_name
    Tier = "public-alb"
  })
}

resource "aws_lb_target_group" "public" {
  name        = var.public_target_group_name
  port        = var.public_alb_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = var.public_health_check_path
    port                = "traffic-port"
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    matcher             = "200-399"
  }

  tags = merge(local.common_tags, {
    Name = var.public_target_group_name
    Tier = "public-alb"
  })
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = var.public_alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public.arn
  }

  tags = local.common_tags
}

# ===========================================================================
# 2) Internal ALB — private load balancer between the Web Tier and the
#    Application Tier. Lives in the two private App Tier subnets, protected
#    by internal-alb-sg (port 3001 from the Web Tier SG only, forwards to the
#    Application Tier only). Never internet-facing; no public IPs anywhere
#    on this resource. No instances are registered yet.
#
#    NOTE: the target group/listener are both HTTP (not TCP) — an
#    Application Load Balancer target group must be HTTP/HTTPS; TCP-protocol
#    target groups only exist on Network Load Balancers, which cannot carry
#    an HTTP listener. See module-level design note in the calling context
#    for the full rationale.
# ===========================================================================

resource "aws_lb" "internal" {
  name               = var.internal_alb_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_alb_sg_id]
  subnets            = var.internal_alb_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(local.common_tags, {
    Name = var.internal_alb_name
    Tier = "internal-alb"
  })
}

resource "aws_lb_target_group" "internal" {
  name        = var.internal_target_group_name
  port        = var.internal_alb_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = var.internal_health_check_path
    port                = "traffic-port"
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    matcher             = "200-399"
  }

  tags = merge(local.common_tags, {
    Name = var.internal_target_group_name
    Tier = "internal-alb"
  })
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = var.internal_alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal.arn
  }

  tags = local.common_tags
}
