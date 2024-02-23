# module to deploy api gateway and lambda that interacts with dynamoDB and cloudwatch logs

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">=4.0.0"
    }
  }
}

provider "aws" {
    region = var.region
    profile = "default"
}


resource "aws_iam_role" "this" {
  name = "${var.project_name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Policies for DynamoDB write access
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "lambda_dynamodb_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:BatchWriteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:868051415142:*"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "this" {
  role = aws_iam_role.this.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_lambda_function" "this" {
  function_name = "tats-project-function"
  handler      = "tats.lambda_handler" #nameoffile.lambdahandler
  runtime      = "python3.9"
  role         = aws_iam_role.this.arn
  filename     = "${path.module}/tats.zip" # Replace with your deployment package

  environment {
    variables = {
      project_name = var.project_name
    }
  }
}

# Archive a single file.Always have to archive program code to use in lambda
data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/tats.py"
  output_path = "${path.module}/tats.zip"
}



# Create an API Gateway to trigger the Lambda function
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project_name}-api"
  
}

resource "aws_api_gateway_resource" "resource1" {
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = var.path
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_method" "GET1" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resource1.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.resource1.id
  http_method = aws_api_gateway_method.GET1.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.this.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.GET1.http_method}${aws_api_gateway_resource.resource1.path}"
}


resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.GET1, aws_api_gateway_integration.this]
}

resource "aws_api_gateway_stage" "staging" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "staging"
}

# Output the API Gateway URL
output "api_gateway_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}

# Create DynamoDB Table
resource "aws_dynamodb_table" "this" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "N"
  }
}

# resource "aws_lambda_function" "example_lambda" {
#   function_name = var.lambda_function_name
#   runtime       = "python3.9"
#   role          = aws_iam_role.lambda_role.arn
#   handler       = "main.lambda_handler"
#   filename      = "my-deployment-package.zip"
#   depends_on = [
#     aws_iam_role_policy_attachment.lambda_logs,
#     aws_cloudwatch_log_group.example,
#   ]
# }
# resource "aws_cloudwatch_log_group" "example" {
#   name              = "/aws/lambda/${var.lambda_function_name}"
#   retention_in_days = 14
# }


#Policy for lambda to send logs to cloudwatch
# resource "aws_iam_policy" "lambda_logging" {
#   name        = "lambda_logging"
#   path        = "/"
#   description = "IAM policy for logging from a lambda"
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource": "arn:aws:logs:*:*:*",
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
# }
