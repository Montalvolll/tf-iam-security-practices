output "ec2_public_ip" {
  value       = module.ec2.public_ip
  description = "Public IP of EC2 instance"
}

output "ec2_instance_arn" {
  value       = module.ec2.instance_arn
  description = "ARN of EC2 instance"
}

output "developers_role_arn" {
  value       = module.iam.developers_role_arn
  description = "IAM Developers role ARN"
}

output "lead_dev_role_arn" {
  value       = module.iam.lead_dev_role_arn
  description = "IAM Lead Developer role ARN"
}

output "rds_endpoint" {
  value       = module.rds.rds_endpoint
  description = "RDS endpoint"
}

output "s3_bucket_name" {
  value       = module.s3.bucket_id
  description = "S3 bucket name"
}

output "s3_bucket_arn" {
  value       = module.s3.bucket_arn
  description = "S3 bucket ARN"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The VPC ID"
}

output "public_1_subnet_id" {
  value       = module.vpc.public_1_subnet_id
  description = "Public subnet ID"
}

output "private_1_subnet_id" {
  value       = module.vpc.private_1_subnet_id
  description = "Private subnet ID"
}

output "rds_password" {
  value       = module.rds.db_password
  description = "RDS instance master password"
  sensitive   = true
}
