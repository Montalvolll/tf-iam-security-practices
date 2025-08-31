variable "tags" { type = map(string) }
variable "s3_bucket_name" { type = string }

# S3 Bucket
resource "aws_s3_bucket" "this" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = var.tags
}

# Versioning for S3 Bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = "Enabled" }
}

# Block Public Access for S3 Bucket
resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Logging for S3 Bucket
resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.this.id

  target_bucket = aws_s3_bucket.this.id
  target_prefix = "log/"
}


output "bucket_id" { value = aws_s3_bucket.this.id }
output "bucket_arn" { value = aws_s3_bucket.this.arn }
