resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_common.id}"

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.name} IGW"
  }
}

# resource "aws_vpc_endpoint" "private_s3" {
#   vpc_id          = "${aws_vpc.main.id}"
#   service_name    = "com.amazonaws.${var.aws_region}.s3"
#   route_table_ids = ["${aws_route_table.public_route_table.id}", "${aws_route_table.private_route_table.id}"]
# }

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    prevent_destroy = false
  }
}
