terraform {
  required_version = ">= 1.10.0"

  # Remote state in S3. Create this bucket manually BEFORE running terraform init.
  # Backend blocks cannot use variables, so edit the values below directly.
  backend "s3" {
    bucket       = "hariprasath-tfstate-ap-south-2" # change to your bucket name
    key          = "portfolio/terraform.tfstate"
    region       = "ap-south-2"
    encrypt      = true
    use_lockfile = true # S3 native locking, no DynamoDB table needed
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "terraform"
    }
  }
}
