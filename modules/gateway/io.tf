variable "king_vpn_remote_state_s3_bucket_name" {}

variable "aws_public_route_table_id" {}

variable "vpc_id" {}

variable "region" {}

variable "customer_gateway_id" {}

variable "consul_address" {}

output "sg_id" {
  value = "${aws_security_group.king_swan_client.id}"
}
