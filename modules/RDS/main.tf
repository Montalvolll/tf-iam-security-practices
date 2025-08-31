variable "tags" { type = map(string) }
variable "db_identifier" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }
variable "db_instance_class" { type = string }
variable "db_engine_version" { type = string }
variable "sg_from_ec2_id" { type = string }
variable "vpc_id" { type = string }
variable "private_1_subnet_id" { type = string }
variable "private_2_subnet_id" { type = string }

// For testing purposes only. In production, I will consider using AWS Secrets Manager.
resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"

}

# Security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "playground-rds-sg"
  description = "Allow Postgres from EC2 SG"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    description     = "Postgres from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.sg_from_ec2_id]
  }

  egress {
    description = "Postgres from EC2"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Subnet group for RDS
resource "aws_db_subnet_group" "this" {
  name       = "playground-dbsubnet"
  subnet_ids = [var.private_1_subnet_id, var.private_2_subnet_id]
  tags       = var.tags
}

resource "aws_db_instance" "postgres-playground" {
  identifier                          = var.db_identifier
  engine                              = "postgres"
  engine_version                      = var.db_engine_version
  instance_class                      = var.db_instance_class
  db_name                             = var.db_name
  username                            = var.db_username
  password                            = random_password.db_password.result
  skip_final_snapshot                 = true
  publicly_accessible                 = false
  allocated_storage                   = 20
  vpc_security_group_ids              = [aws_security_group.rds_sg.id]
  db_subnet_group_name                = aws_db_subnet_group.this.name
  tags                                = var.tags
  storage_encrypted                   = true
  auto_minor_version_upgrade          = true
  iam_database_authentication_enabled = true
  performance_insights_enabled        = true
  copy_tags_to_snapshot               = true
  # enabled_cloudwatch_logs_exports     = ["general", "error", "slowquery"]
  # multi_az                            = true
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true

}

output "rds_endpoint" { value = aws_db_instance.postgres-playground.endpoint }
output "rds_arn" { value = aws_db_instance.postgres-playground.arn }
