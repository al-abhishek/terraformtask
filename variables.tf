variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "S3 Bucket Name"
  type        = string
  default     = "abhi-demo-2026-event"
}

variable "dynamodb_name" {
  description = "dynamo db table"
  type = string
  default = "payload-table"
}