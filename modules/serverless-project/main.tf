
provider "aws" {
  region = "us-east-1" 
  profile = "default"
}

# Create an AWS Lambda function
resource "aws_lambda_function" "example_lambda" {
  function_name = "example_lambda_function"
  handler      = "index.handler"
  runtime      = "nodejs14.x"
  role         = aws_iam_role.lambda_role.arn
  filename     = "path/to/your/lambda_function.zip" # Replace with your deployment package

  environment {
    variables = {
      ENV_VAR_KEY = "ENV_VAR_VALUE"
    }
  }
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "example_lambda_role"

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

# Attach an IAM policy to the Lambda role for basic Lambda permissions
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Create an API Gateway to trigger the Lambda function
resource "aws_api_gateway_rest_api" "example_api" {
  name        = "example_api"
  description = "Example API"
}

resource "aws_api_gateway_resource" "example_api_resource" {
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "example"
  rest_api_id = aws_api_gateway_rest_api.example_api.id
}

resource "aws_api_gateway_method" "example_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "example_api_integration" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  resource_id = aws_api_gateway_resource.example_api_resource.id
  http_method = aws_api_gateway_method.example_api_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.example_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "example_api_deployment" {
  depends_on = [aws_api_gateway_integration.example_api_integration]
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  stage_name  = "prod"
}

# Output the API Gateway URL
output "api_gateway_url" {
  value = aws_api_gateway_deployment.example_api_deployment.invoke_url
}