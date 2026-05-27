resource "aws_api_gateway_rest_api" "api" {

  name = "event-driven-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Resource

resource "aws_api_gateway_resource" "resource" {

  rest_api_id = aws_api_gateway_rest_api.api.id

  parent_id = aws_api_gateway_rest_api.api.root_resource_id

  path_part = "send"
}

# POST Method

resource "aws_api_gateway_method" "method" {

  rest_api_id = aws_api_gateway_rest_api.api.id

  resource_id = aws_api_gateway_resource.resource.id

  http_method = "POST"

  authorization = "NONE"
}

# API Gateway → SQS Integration

resource "aws_api_gateway_integration" "integration" {

  rest_api_id = aws_api_gateway_rest_api.api.id

  resource_id = aws_api_gateway_resource.resource.id

  http_method = aws_api_gateway_method.method.http_method

  integration_http_method = "POST"

  type = "AWS"

  uri = "arn:aws:apigateway:${var.aws_region}:sqs:path/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.payload_queue.name}"

  credentials = aws_iam_role.apigw_role.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$util.urlEncode($input.body)"
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}

# Method Response

resource "aws_api_gateway_method_response" "response_200" {

  rest_api_id = aws_api_gateway_rest_api.api.id

  resource_id = aws_api_gateway_resource.resource.id

  http_method = aws_api_gateway_method.method.http_method

  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# Integration Response

resource "aws_api_gateway_integration_response" "integration_response" {

  rest_api_id = aws_api_gateway_rest_api.api.id

  resource_id = aws_api_gateway_resource.resource.id

  http_method = aws_api_gateway_method.method.http_method

  status_code = "200"

  response_templates = {
    "application/json" = jsonencode({
      message = "Message sent successfully"
    })
  }

  depends_on = [
    aws_api_gateway_integration.integration
  ]
}

# Deployment

resource "aws_api_gateway_deployment" "deployment" {

  depends_on = [
    aws_api_gateway_integration.integration,
    aws_api_gateway_method_response.response_200,
    aws_api_gateway_integration_response.integration_response
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.resource.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.integration.id,
      aws_api_gateway_method_response.response_200.id,
      aws_api_gateway_integration_response.integration_response.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Stage

resource "aws_api_gateway_stage" "stage" {

  deployment_id = aws_api_gateway_deployment.deployment.id

  rest_api_id = aws_api_gateway_rest_api.api.id

  stage_name = "dev"
}