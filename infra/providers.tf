terraform {
  required_version = ">= 1.10"

  # state は専用の S3 バケットに保存（バージョニング有効、S3 ネイティブロック）
  backend "s3" {
    bucket       = "wangyuanpei-2026-tfstate"
    key          = "cloud-resume/terraform.tfstate"
    region       = "ap-southeast-2"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}
