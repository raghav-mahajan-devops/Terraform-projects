terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "terraform-bucket-multi-instance"
    key    = "automate-ec2-multi-instance/terraform.tfstate"
    region = "us-west-2"
}
}

provider "aws" {
  region = "us-west-2"
}