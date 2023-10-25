resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_organizations_organizational_unit" "this" {
  name = "Test OU"
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "random_pet" "this" {
  length = 1
}

locals {
  account_name = "TestAccount"
  user_id_parts = split("@", var.root_email)
  account_email_parts = [local.user_id_parts[0], local.account_name, random_pet.this.id]
  account_email_name = join("+", local.account_email_parts)
  account_email = "${local.account_email_name}@${local.user_id_parts[1]}"
}

resource "aws_organizations_account" "this" {
  name = "Test Account"
  email = local.account_email
  parent_id = aws_organizations_organizational_unit.this.id
  close_on_deletion = true
}

provider "aws" {
  alias = "account"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.this.id}:role/OrganizationAccountAccessRole"
    session_name = "Terraform_AccountSession"
  }
}

resource "time_sleep" "delay" {
  depends_on = [aws_organizations_account.this]
  create_duration = "60s"
}

resource "aws_s3_bucket" "test" {
  bucket = "com.thinkatoz.${aws_organizations_account.this.id}.test-bucket"

  provider = aws.account
  depends_on = [ time_sleep.delay ]
}

output "account_email" {
  value = local.account_email
}
