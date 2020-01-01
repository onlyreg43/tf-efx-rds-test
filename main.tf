# Terraform state will be stored in S3 ok
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

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

resource "aws_security_group" "orcdb-test" 
{
  name = "orcdb-test"
  description = "RDS Oracle servers (terraform-managed)"
  vpc_id = "${var.rds_vpc_id}"

  # Only postgres in
  ingress 
  {
    from_port = 1521
    to_port = 1521
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress 
  {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create RDS instance
resource "aws_db_instance" "demodb-orcl"
{
  identifier        = "demodb-oracle"
  engine            = "oracle-se1"
  engine_version    = "11.2.0.4.v22"
  instance_class    = "db.t3.micro"
  allocated_storage = 10
  storage_encrypted = false
  license_model     = "bring-your-own-license"
  name              = "DEMO-EFX-DB"
  username          = "rj-efx-tst"
  password          = "rj-efx-tst-12!"
  port              = "1521"
  iam_database_authentication_enabled = false
  vpc_security_group_ids = [data.aws_security_group.default.id]
  # DB subnet group
  subnet_ids = data.aws_subnet_ids.all.ids
  # DB parameter group
  family = "oracle-se1-11-2"
  # DB option group
  major_engine_version = "11.2"
  # character sets 
  character_set_name = "AL32UTF8"
  # Database Deletion Protection
  deletion_protection = false

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
  }