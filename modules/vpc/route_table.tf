resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  # Do not use route block here. Use aws_route instead ...
  tags {
    Name = "${var.name} Public Route Table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  # Do not use route block here. Use aws_route instead ...
  tags {
    Name = "${var.name} Private Route Table"
  }
}

resource "aws_route" "public_route_table_igw" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

resource "aws_route" "private_route_table_nat_gw" {
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_gw.id}"
}
