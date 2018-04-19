module "king_vpc" {
  source = "git@github.com:devsisters/king-openvpn.git?ref=modules//modules/vpc"

  name       = "king-vpc"
  aws_region = "ap-northeast-1"
  az_main    = "a"
  az_sub     = "c"
  cidr_block = "${var.cidr_block}"
}
