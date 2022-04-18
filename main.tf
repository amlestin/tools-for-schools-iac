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

locals {
  verbal_api_lambda_name    = "verbal_api_lambda"
  verbal_api_lambda_handler = "handler"
}

data "archive_file" "verbal_lambda_zip" {
  type        = "zip"
  source_file = "bin/verbal_api"
  output_path = "bin/verbal_api.zip"
}

data "aws_iam_policy_document" "verbal_api_trust_policy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "verbal_api_lambda_role" {
  name = "verbal_api_lambda_role"
  assume_role_policy = "${data.aws_iam_policy_document.verbal_api_trust_policy.json}"
}

resource "aws_iam_role_policy_attachment" "verbal_api_basic_execution" {
  role = aws_iam_role.verbal_api_lambda_role.arn
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_lambda_function" "verbal_api_lambda" {
  filename      = data.archive_file.verbal_lambda_zip.output_path
  function_name = local.verbal_api_lambda_name
  role          = aws_iam_role.verbal_api_lambda_role.arn
  handler       = local.verbal_api_lambda_handler
  runtime       = "go1.x"
  memory_size   = 256
  timeout       = 30
}
