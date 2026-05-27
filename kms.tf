resource "aws_kms_key" "s3_kms" {
  description             = "KMS Key for S3 Encryption"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "s3_alias" {
  name          = "alias/s3kmskey"
  target_key_id = aws_kms_key.s3_kms.key_id
}