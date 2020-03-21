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
    length = 22
  }
}

resource "secrethub_secret" "db_user" {
  path = "${local.secrethub_dir}/db/user"
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
  password = secrethub_secret.db_password.value
  publicly_accessible = true
  final_snapshot_identifier = "tirgus-api-db-final-SNAPSHOT"
  parameter_group_name = "default.postgres9.6"

}


