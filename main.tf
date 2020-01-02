# Terraform state will be stored in S3 ok
terraform {
  backend "s3" {
    bucket = "terraform-bucket-test-efx"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

#Use AWS Terraform provider
provider "aws" {
version = "~> 2.0"
region = "us-east-2"
}

#############################################################
# Data sources to get VPC, subnets and security group details
#############################################################
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

resource "aws_security_group" "orcdb-test" {
  name = "orcdb-test"
  description = "RDS Oracle servers (terraform-managed)"
  vpc_id = "${var.rds_vpc_id}"

ingress {
   from_port = 1521
   to_port = 1521
   protocol = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
}

egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

##############################################################################################################
# Create RDS Oracle DB
##############################################################################################################
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "demodb-oracle"

  engine            = "oracle-se1"
  engine_version    = "11.2.0.4.v22"
  instance_class    = "db.t3.micro"
  allocated_storage = 10
  storage_encrypted = false
  license_model     = "bring-your-own-license"
  # Make sure that database name is capitalized, otherwise RDS will try to recreate RDS instance every time
  name                                = "DEMOEFX"
  username                            = "efxdba"
  password                            = "efxdba2019"
  port                                = "1521"
  iam_database_authentication_enabled = false
  vpc_security_group_ids = [data.aws_security_group.default.id]
  subnet_ids             = data.aws_subnet_ids.all.ids
  family                 = "oracle-se1-11.2"
  major_engine_version   = "11.2"
  character_set_name     = "AL32UTF8"
  deletion_protection    = false
  maintenance_window     = "Mon:00:00-Mon:03:00"
  backup_window          = "03:00-06:00"
  #disable backups to create DB faster
  backup_retention_period = 0
  publicly_accessible    = true
  skip_final_snapshot    = true
  multi_az               = false
  
  tags = {
    Owner       = "user"
    Environment = "efx-Dev"
  }
}