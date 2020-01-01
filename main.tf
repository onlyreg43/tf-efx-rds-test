# Terraform state will be stored in S3
terraform {
  backend "s3" {
    bucket = "terraform-bucket-test-efx"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

# Use AWS Terraform provider
provider "aws" {
  region = "us-east-2"
}

# Create EC2 instance
resource "aws_instance" "default" {
  ami                    = "${var.ami}"
  count                  = "${var.count-1}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  source_dest_check      = false
  instance_type          = "${var.instance_type}"

  tags = {
    Name = "terraform-efx-default"
  }
}


