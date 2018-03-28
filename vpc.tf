module "king-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "king-vpc"

  cidr = "${var.cidr_block}"

  azs            = "${var.azs}"
  public_subnets = "${var.public_subnet_cidr_blocks}"

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
  }
}
