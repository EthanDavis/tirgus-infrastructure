provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "poc-terraformstate"
    key = "poc/tirgus-infrastructure/"
    region = "us-east-2"
  }
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "db_credentials" {
  name = "poc/postrges-credentials"
}

resource "aws_db_instance" "postgres_instance" {
  allocated_storage = 20
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "9.6.3"
  instance_class = "db.t2.micro"
  name = "tirgus-api-db"
  username = "${data.aws_secretsmanager_secret.db_credentials["user"]}"
  password = "${data.aws_secretsmanager_secret.db_credentials["password"]}"
  family = "postgres9.6"
}