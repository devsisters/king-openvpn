variable "name" {}

variable "cidr_block" {}

variable "aws_region" {}

variable "az_main" {}

variable "az_sub" {}

output "aws_public_route_table_id" {
  value = "${aws_route_table.public_route_table.id}"
}

output "aws_private_route_table_id" {
  value = "${aws_route_table.private_route_table.id}"
}

output "vpc_name" {
  value = "${var.name}"
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "az_main" {
  value = "${var.az_main}"
}

output "az_sub" {
  value = "${var.az_sub}"
}

output "cidr_block" {
  value = "${var.cidr_block}"
}

output "public_common_subnet_id" {
  value = "${aws_subnet.public_common.id}"
}
