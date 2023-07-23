terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                 = "${terraform.workspace}-iac"
}
