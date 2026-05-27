resource "aws_sqs_queue" "payload_queue" {
  name = "payload-queue"
}

resource "aws_sqs_queue_policy" "queue_policy" {

  queue_url = aws_sqs_queue.payload_queue.id

  policy = jsonencode({
    Version = "2012-10-17",

    Statement = [
      {
        Sid = "AllowAPIGatewaySendMessage",

        Effect = "Allow",

        Principal = {
          AWS = aws_iam_role.apigw_role.arn
        },

        Action = "sqs:SendMessage",

        Resource = aws_sqs_queue.payload_queue.arn
      }
    ]
  })
}