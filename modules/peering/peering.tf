provider "aws" {
  alias  = "local"
  region = "${var.local_region}"
}

provider "aws" {
  alias  = "remote"
  region = "${var.remote_region}"
}

data "aws_vpc" "local" {
  provider = "aws.local"
  id       = "${var.local_vpc_id}"
}

data "aws_vpc" "remote" {
  provider = "aws.remote"
  id       = "${var.remote_vpc_id}"
}

data "aws_caller_identity" "remote" {
  provider = "aws.remote"
}

resource "aws_vpc_peering_connection" "local" {
  provider = "aws.local"

  peer_owner_id = "${data.aws_caller_identity.remote.account_id}"
  vpc_id        = "${var.local_vpc_id}"
  peer_vpc_id   = "${var.remote_vpc_id}"
  peer_region   = "${var.remote_region}"

  tags {
    Name = "VPC Peering between ${data.aws_vpc.local.tags["Name"]} and ${data.aws_vpc.remote.tags["Name"]}"
  }
}

resource "aws_vpc_peering_connection_accepter" "remote" {
  provider                  = "aws.remote"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.local.id}"
  auto_accept               = true

  tags {
    Name = "VPC Peering between ${data.aws_vpc.local.tags["Name"]} and ${data.aws_vpc.remote.tags["Name"]}"
  }
}

resource "aws_route" "public_route_table_peering_local" {
  provider                  = "aws.local"
  route_table_id            = "${var.local_public_route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.remote.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.local.id}"
}

resource "aws_route" "private_route_table_peering_local" {
  provider                  = "aws.local"
  route_table_id            = "${var.local_private_route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.remote.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.local.id}"
}

resource "aws_route" "public_route_table_peering_remote" {
  provider                  = "aws.remote"
  route_table_id            = "${var.remote_public_route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.local.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.local.id}"
}

resource "aws_route" "private_route_table_peering_remote" {
  provider                  = "aws.remote"
  route_table_id            = "${var.remote_private_route_table_id}"
  destination_cidr_block    = "${data.aws_vpc.local.cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.local.id}"
}
