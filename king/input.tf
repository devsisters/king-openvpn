variable "profile" {
  description = "AWS profile to use for deployment"
}

variable "region" {
  description = "Region to deploy the king-swan"
  default     = "ap-northeast-1"
}

variable "azs" {
  description = "List of availability zones to deploy the king-swan"

  default = [
    "ap-northeast-1a",

    # "ap-northeast-1b",
    "ap-northeast-1c",

    "ap-northeast-1d",
  ]
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "172.29.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "The CIDR block for the public subnets"

  default = [
    "172.29.0.0/18",
    "172.29.64.0/18",
    "172.29.128.0/18",
    "172.29.192.0/18",
  ]
}

variable "public_key_name" {
  description = "The name of the key to user for ssh access"
}

variable "public_key_path" {
  description = "The local public key path"
}

variable "openvpn_admin_password" {
  description = "OpenVPN admin password"
}
