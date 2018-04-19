variable "cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "172.29.0.0/16"
}

variable "public_key_name" {
  description = "The name of the key to user for ssh access"
}

variable "openvpn_admin_password" {
  description = "OpenVPN admin password"
}

variable "remote_state_s3_bucket_name" {
  description = "S3 bucket name for remote state store"
}
