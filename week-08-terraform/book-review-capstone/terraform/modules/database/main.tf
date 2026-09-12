locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  # ---------------------------------------------------------------------------
  # Replica AZ placement
  #
  # The AWS RDS API rejects an explicit `AvailabilityZone` on an instance that
  # has `multi_az = true` (AWS chooses/rotates the primary's AZ and places the
  # standby in the other AZ automatically). Because of this, the primary's AZ
  # is intentionally left unmanaged below and is only known after apply.
  #
  # The read replica is a single-AZ resource, so we *can* pin its AZ — and we
  # want it spread away from wherever the primary landed rather than left to
  # chance. Since the primary's AZ is only known after apply, this comparison
  # itself only resolves at apply time (it will show as "known after apply"
  # in `terraform plan`, which is expected and not an error).
  # ---------------------------------------------------------------------------
  replica_availability_zone = (
    aws_db_instance.primary.availability_zone == var.availability_zones[0]
    ? var.availability_zones[1]
    : var.availability_zones[0]
  )
}

# ---------------------------------------------------------------------------
# DB Subnet Group — spans both private Database Tier subnets so RDS can
# place the Multi-AZ primary/standby and the read replica across both AZs.
# ---------------------------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  name        = "${var.project_name}-db-sg"
  description = "Database Tier subnet group spanning both private DB subnets for Multi-AZ placement."
  subnet_ids  = var.private_db_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-db-subnet-group"
    Tier = "db"
  })
}

# ---------------------------------------------------------------------------
# Primary — Multi-AZ MySQL instance.
#
# Security: publicly_accessible = false and vpc_security_group_ids restrict
# this instance to the db-sg, which itself only accepts MySQL (3306) from
# the Application Tier security group (see modules/security/main.tf).
#
# Credentials: master_password is supplied as a sensitive variable (never
# hardcoded, never output). AWS does not support Secrets Manager-managed
# passwords on instances with read replicas, so we use an explicit password.
# The password is stored in Terraform state (gitignored) — never commit
# state files or expose the password variable.
#
# apply_immediately = true makes the credential change take effect now
# rather than waiting for the next maintenance window. This is important
# because apply_immediately allows the read replica to use the new password.
#
# Multi-AZ: multi_az = true provisions a synchronously-replicated standby
# in the second AZ, with automatic failover. AWS chooses/manages the AZ
# placement for Multi-AZ instances, so `availability_zone` is intentionally
# omitted here (see local.replica_availability_zone comment above).
#
# Lab setting: skip_final_snapshot = true means this instance can be
# destroyed without a final snapshot — acceptable for this lab/capstone
# environment, not recommended for a real production database.
# ---------------------------------------------------------------------------

resource "aws_db_instance" "primary" {
  identifier = "${var.project_name}-mysql-primary"

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  db_name  = "book_review_db"
  username = var.master_username
  password = var.master_password

  apply_immediately       = true
  multi_az                = true
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-mysql-primary"
    Tier = "db"
    Role = "primary"
  })
}

# ---------------------------------------------------------------------------
# Read Replica — asynchronous, single-AZ replica of the primary.
#
# Placed in whichever AZ the primary did NOT land in (see
# local.replica_availability_zone), for AZ-level read spread.
#
# username/password/db_name are intentionally omitted: AWS does not accept
# these on a read replica — it inherits them from replicate_source_db.
# ---------------------------------------------------------------------------

resource "aws_db_instance" "replica" {
  identifier          = "${var.project_name}-mysql-replica"
  replicate_source_db = aws_db_instance.primary.identifier
  instance_class      = var.db_instance_class
  availability_zone   = local.replica_availability_zone

  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  skip_final_snapshot = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-mysql-replica"
    Tier = "db"
    Role = "replica"
  })
}
