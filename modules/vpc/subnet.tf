resource "aws_subnet" "public_common" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(var.cidr_block, 24-replace(var.cidr_block,"/.*//",""), 0)}"
  availability_zone       = "${var.aws_region}${var.az_main}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}.public_common"
  }
}

resource "aws_route_table_association" "public_common" {
  subnet_id      = "${aws_subnet.public_common.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}