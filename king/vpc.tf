provider "aws" {
  alias  = "abc"
  region = "us-west-1"
}

module "king_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = "aws.abc"
  }

  name = "king-vpc"

  cidr = "${var.cidr_block}"

  azs             = "${var.azs}"
  public_subnets  = "${var.public_subnet_cidr_blocks}"
  private_subnets = "${var.private_subnet_cidr_blocks}"

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
  }
}
