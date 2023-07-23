#----------
# Data Sources
#----------
data "aws_iam_policy" "aws_lambda_basic_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#----------
# IAM
#----------
resource "aws_iam_role" "lambda" {
  name = "${var.project}-lambda-role"

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
  image_uri     = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.project}-${var.repository_name}:latest"
  lifecycle {
    ignore_changes = [image_uri]
  }
  memory_size = 256
  timeout     = 3
}
