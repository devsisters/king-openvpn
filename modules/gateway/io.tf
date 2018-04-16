variable "profile" {
  description = "AWS profile to use for deployment"
}

variable "king_vpn_remote_state_s3_bucket_name" {}

variable "vpc_id" {}

variable "aws_public_route_table_id" {}

variable "vpc_cidr_block" {}

variable "customer_gateway_id" {}

variable "consul_address" {}

variable "public_key_name" {
  description = "The name of the key to user for ssh access"
}

variable "public_key_path" {
  description = "The local public key path"
}

output "sg_id" {
  value = "${aws_security_group.king-swan-client.id}"
}
