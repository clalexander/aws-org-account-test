variable "aws_region" {}
# variable "remote_state_bucket" {}
# variable "remote_state_key" {}
# variable "remote_state_lock" {}

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = "~> 5.0"
  }

  backend "s3" {
    region = var.aws_region
    bucket = var.remote_state_bucket
    key = var.remote_state_key
    dynamodb_table = var.remote_state_lock
  }
}

provider "aws" {
  region = var.aws_region
}