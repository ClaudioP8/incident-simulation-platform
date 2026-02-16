terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "prod-incident-terraform-state-250205157846"
    key            = "global/bootstrap/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
