provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

terraform {
  backend "s3" {
    bucket  = "king-terraform-state"
    key     = "king-swan.tfstate"
    region  = "ap-northeast-1"
    encrypt = "true"
  }
}
