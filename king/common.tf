provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket  = "<<< YOUR REMOTE STATE S3 BUCKET NAME >>>"
    key     = "king-vpn/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = "true"
  }
}
