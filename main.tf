provider "aws" {
  region = var.region
}

provider "secrethub" {
  credential = file("~/.secrethub/credential")
}

terraform {
  backend "s3" {
    bucket = "poc-terraformstate"
    key = "poc/tirgus-infrastructure/"
    region = "us-east-2"
  }
}

data "aws_caller_identity" "current" {}


locals {
  secrethub_dir = "tirgus-api/poc"
}

resource "secrethub_secret" "db_password" {
  path = "${local.secrethub_dir}/db/password"

  generate {
    length      = 22
    use_symbols = true
  }
}

resource "secrethub_secret" "db_user" {
  path  = "${local.secrethub_dir}/db/user"
  value = "schema_user"
}

resource "aws_db_instance" "postgres_instance" {
  allocated_storage = 20
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "9.6.3"
  instance_class = "db.t2.micro"
  name = "tirgusApiDb"
  identifier = "tirgus-api-db"
  username = secrethub_secret.db_user.value
  password =  secrethub_secret.db_password.value
  parameter_group_name = aws_db_parameter_group.postgres_db.name
}


resource "aws_db_parameter_group" "postgres_db" {
  name   = "postgres-database"
  family = "postgres9.6"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }
}