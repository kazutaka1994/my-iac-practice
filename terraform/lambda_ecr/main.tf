
#----------
# ECR
#----------
resource "aws_ecr_repository" "terraform_ecr_repository" {
  encryption_configuration {
#tfsec:ignore:aws-ecr-repository-customer-key
    encryption_type = var.encryption_type
  }

  image_scanning_configuration {
    scan_on_push = "true"
  }

  image_tag_mutability = "IMMUTABLE"
  name                 = "${terraform.workspace}-${var.repository_name}-repository"
}

#----------
# ECR Policy
#----------
resource "aws_ecr_lifecycle_policy" "terraform_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.terraform_ecr_repository.name
  policy     = jsonencode(local.ecr-lifecycle-policy)
}

#----------
# IAM Role For Lambda Funciton
#----------
resource "aws_iam_role" "lambda" {
  name = "example-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}
#----------
# Attach IAM Policy to IAM Role
#----------
resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = data.aws_iam_policy.aws_lambda_basic_execution_role.arn
}

#----------
# Lambda function
#----------
#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "this" {
  function_name = "${var.project}-${var.lambda_function_name}"
  description   = "Lambda Function for ${var.project}"

  role          = aws_iam_role.lambda.arn
  architectures = ["x86_64"]
  runtime       = var.runtime
  handler       = var.handler
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.terraform_ecr_repository.repository_url}:latest"
  lifecycle {
    ignore_changes = [image_uri]
  }

  memory_size = 256
  timeout     = 3
}

output "ecr_url" {
  value = aws_ecr_repository.terraform_ecr_repository.repository_url
}