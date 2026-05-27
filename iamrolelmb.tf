resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


//policy of lambda

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      {
        Effect = "Allow",
        Action = [
          "sqs:*"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "dynamodb:*"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt"
        ],
        Resource = "*"
      },

      {
        Effect = "Allow",
        Action = [
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  })
}