data "aws_vpc" "local_vpc" {
  id = "${var.local_vpc_id}"
}

data "aws_vpc" "remote_vpc" {
  id = "${var.remote_vpc_id}"
}

resource "aws_vpc_peering_connection" "conn" {
  peer_vpc_id = "${var.remote_vpc_id}"
  vpc_id      = "${var.local_vpc_id}"
  auto_accept = true

  tags {
    Name = "VPC Peering between ${data.aws_vpc.local_vpc.tags["Name"]} and ${data.aws_vpc.remote_vpc.tags["Name"]}"
  }
}

resource "aws_route" "public_route_table_peering_local" {
  route_table_id            = "${var.local_public_route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.remote_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.conn.id}"
}

resource "aws_route" "private_route_table_peering_local" {
  route_table_id            = "${var.local_private_route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.remote_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.conn.id}"
}

resource "aws_route" "public_route_table_peering_remote" {
  route_table_id            = "${var.remote_public_route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.local_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.conn.id}"
}

resource "aws_route" "private_route_table_peering_remote" {
  route_table_id            = "${var.remote_private_route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.local_vpc.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.conn.id}"
}

