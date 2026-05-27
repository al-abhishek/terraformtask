resource "aws_lambda_function" "processor" {

  filename      = "lambda/lambda.zip"
  function_name = "payload-processor"

  role    = aws_iam_role.lambda_role.arn
  handler = "index.handler"
  runtime = "nodejs16.x"
  source_code_hash = filebase64sha256("lambda/lambda.zip")

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.my_table.name
      BUCKET_NAME = aws_s3_bucket.my_bucket.bucket
      SECRET_NAME = aws_secretsmanager_secret.app_secret.name
    }
  }
}





# SQS Trigger to Lambda

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.payload_queue.arn
  function_name    = aws_lambda_function.processor.arn
}

# API Gateway IAM Role

resource "aws_iam_role" "apigw_role" {

  name = "apigw-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# pilicy
resource "aws_iam_role_policy" "apigw_policy" {

  role = aws_iam_role.apigw_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "sqs:SendMessage"
      ],
      Resource = aws_sqs_queue.payload_queue.arn
    }]
  })
}