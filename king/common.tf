provider "aws" {
  region  = "ap-northeast-1"
  profile = "${var.profile}"
}

data "terraform_remote_state" "king_vpn" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_s3_bucket_name}"
    key    = "king-vpn/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
