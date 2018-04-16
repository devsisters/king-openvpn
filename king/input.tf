variable "profile" {
  description = "AWS profile to use for deployment"
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
    "172.29.0.0/17",
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "The CIDR block for the private subnets"

  default = [
    "172.29.128.0/17",
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

variable "remote_state_s3_bucket_name" {
  description = "S3 bucket name for remote state store"
}
