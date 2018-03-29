provider "aws" {
  region = "${var.region}"
  alias  = "${var.profile}"
}

data "terraform_remote_state" "king-swan" {
  backend = "s3"

  config {
    bucket = ""
    key    = ""
    region = "ap-northeast-1"
  }
}

locals {
  king_vpc_cidr_block = "172.16.0.0/16"
}
