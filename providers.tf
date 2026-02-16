provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::250205157846:role/TerraformDeployRole"
  }
}
