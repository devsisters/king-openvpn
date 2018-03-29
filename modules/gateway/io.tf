variable "profile" {
  description = "AWS profile to use for deployment"
}

variable "region" {
  description = "Region to deploy the king-swan"
  default     = "ap-northeast-1"
}

variable "vpc_id" {}

variable "aws_public_route_table_id" {}

variable "vpc_cidr_block" {}

variable "customer_gateway_id" {}

variable "consul_address" {}

output "sg_id" {
  value = "${aws_security_group.king-swan-client.id}"
}

variable "public_key_name" {
  description = "The name of the key to user for ssh access"
}

variable "public_key_path" {
  description = "The local public key path"
}
