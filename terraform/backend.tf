# S3 Backend Configuration
#
# IMPORTANT: This backend is commented out by default.
# Follow these steps to enable it:
#
# 1. First run: terraform init
#    (This initializes Terraform with local state)
#
# 2. Create the S3 bucket and DynamoDB table for remote state:
#    - Run: terraform apply
#    - This creates the initial resources
#
# 3. Uncomment the backend block below
#
# 4. Run: terraform init -migrate-state
#    This migrates the local state to the S3 backend
#
# Once enabled, all subsequent terraform operations will use remote state.

# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket"
#     key            = "portfolio-site/terraform.tfstate"
#     region         = "ap-south-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }
