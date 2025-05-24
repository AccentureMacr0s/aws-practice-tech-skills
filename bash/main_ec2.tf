# main.tf - EC2 provisioning module

provider "aws" {
  region = var.region
}

module "ec2_instance" {
  source = "./modules/ec2"
  instance_name = var.instance_name
  ami_id        = var.ami_id
  instance_type = var.instance_type
  tags = {
    RunAutomation = "true"
    Environment   = "production"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "cloud-automation-logs"
  force_destroy = true
}

resource "aws_sns_topic" "automation_alerts" {
  name = "cloud-automation-topic"
}

resource "aws_iam_role" "automation_role" {
  name = "CloudAutomationRole"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_log_group" "automation" {
  name = "/aws/cloud-automation"
  retention_in_days = 7
}