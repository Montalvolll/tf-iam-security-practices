variable "tags" { type = map(string) }
variable "bucket_arn" { type = string }
variable "bucket_name" { type = string }
variable "rds_arn" { type = string }
variable "instance_arn" { type = string }

# Instance Role allowing read/write OBJECTS only, also list the bucket
data "aws_iam_policy_document" "ec2_s3_rw_objects" {
  statement {
    sid       = "S3ObjectRW"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:PutObjectAcl", "s3:ListBucket"]
    resources = [var.bucket_arn, "${var.bucket_arn}/*"]
  }
}

# IAM policy for EC2 to read/write objects in S3 bucket
resource "aws_iam_policy" "ec2_s3_rw_objects" {
  name        = "playground-ec2-s3-objects"
  description = "EC2 can read/write objects but cannot change bucket configuration"
  policy      = data.aws_iam_policy_document.ec2_s3_rw_objects.json
}

# Instance Profile and Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "playground-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

# Attach the S3 read/write policy to the EC2 role
resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_rw_objects.arn
}

# Instance profile for EC2 to use the above role
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "playground-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Developers group: EC2 start/stop + S3 READ + RDS Describe
data "aws_iam_policy_document" "developers" {
  statement {
    sid       = "EC2StartStop"
    actions   = ["ec2:StartInstances", "ec2:StopInstances", "ec2:Describe*"]
    resources = [var.instance_arn]
  }
  statement {
    sid       = "S3ReadObjsOnly"
    actions   = ["s3:GetObject", "s3:ListBucket", "s3:GetBucketLocation"]
    resources = [var.bucket_arn, "${var.bucket_arn}/*"]
  }
  # let the console list bucket names in the account
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    sid       = "RDSDescribe"
    actions   = ["rds:Describe*", "rds:ListTagsForResource"]
    resources = [var.rds_arn]
  }
}

# Policy for Developers 
resource "aws_iam_policy" "developers" {
  name        = "playground-developers-policy"
  policy      = data.aws_iam_policy_document.developers.json
  description = "Developers can start/stop EC2, read S3 objects, describe RDS"
}

# Developers role: can assume role, includes same policy as group
resource "aws_iam_role" "developers_role" {
  name = "playground-developers"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { AWS = "*" }, # This will be replaced once the ARNs are known
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

# Reusing the existing Developers policy (start/stop EC2, S3 read, RDS describe)
resource "aws_iam_role_policy_attachment" "developers_role_attach" {
  role       = aws_iam_role.developers_role.name
  policy_arn = aws_iam_policy.developers.arn
}

# Lead Developer role: can assume role, includes write to S3 + broader describe
data "aws_iam_policy_document" "lead_dev" {
  statement {
    sid       = "DevEC2StartStop"
    actions   = ["ec2:StartInstances", "ec2:StopInstances", "ec2:DescribeInstances"]
    resources = [var.instance_arn]
  }
  statement {
    sid       = "S3ReadObjsOnly"
    actions   = ["s3:GetObject", "s3:ListBucket", "s3:GetBucketLocation"]
    resources = [var.bucket_arn, "${var.bucket_arn}/*"]
  }
  # let the console list bucket names in the account
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
  statement {
    actions = ["rds:Describe*", "rds:ModifyDBInstance", "rds:ListTagsForResource"]
    # ModifyDBInstance is the most accurate for limited write perms
    resources = [var.rds_arn]
  }
}

resource "aws_iam_policy" "lead_dev" {
  name        = "playground-leaddev-policy"
  policy      = data.aws_iam_policy_document.lead_dev.json
  description = "Lead Dev can start/stop EC2, read/write S3, describe/modify RDS"
}

resource "aws_iam_role" "lead_dev_role" {
  name = "playground-lead-developer-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow",
      Principal = { AWS = "*" }, # This will be replaced once the ARNs are known
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags

}

resource "aws_iam_role_policy_attachment" "lead_dev_attach" {
  role       = aws_iam_role.lead_dev_role.name
  policy_arn = aws_iam_policy.lead_dev.arn
}

output "ec2_instance_profile_name" { value = aws_iam_instance_profile.ec2_profile.name }
output "lead_dev_role_arn" { value = aws_iam_role.lead_dev_role.arn }
output "developers_role_arn" { value = aws_iam_role.developers_role.arn }
