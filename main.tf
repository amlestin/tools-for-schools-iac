terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "archive_file" "verbal_lambda_zip" {
  type        = "zip"
  source_file = "bin/verbal_api"
  output_path = "bin/verbal_api.zip"
}
