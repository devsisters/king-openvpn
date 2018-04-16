provider "aws" {
  region = "ap-northeast-1"
  alias  = "${var.profile}"
}

data "terraform_remote_state" "king_vpn" {
  backend = "s3"

  config {
    bucket = "${var.king_vpn_remote_state_s3_bucket_name}"
    key    = "king-vpn/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

locals {
  king_vpc_cidr_block = "172.16.0.0/16"
}
