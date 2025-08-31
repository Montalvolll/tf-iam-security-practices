variable "tags" {
  type        = map(string)
  description = "Default tags for playground."
  default = {
    Environment = "Dev"
    Project     = "My Playground"
  }
}

variable "my_ip" {
  type        = string
  description = "Your IP address in CIDR notation (e.g., 1.2.3.4/32) for SSH access"
  default     = "0.0.0.0/0" # Replace with your actual IP address
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type."
  default     = "t3.micro"

}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name to create."
  default     = "myplayground-bucket-23dcwe4f23434f"

}

variable "db_identifier" {
  type        = string
  description = "The RDS instance identifier."
  default     = "myplayground-db-instance"
}

variable "db_name" {
  type        = string
  description = "The name of the database to create when the DB instance is created."
  default     = "myplaygrounddb"
}

variable "db_username" {
  type        = string
  description = "The username for the database."
  default     = "admindbuser"
}

variable "db_instance_class" {
  type        = string
  description = "The instance type of the RDS instance."
  default     = "db.t3.micro"
}

variable "db_engine_version" {
  type        = string
  description = "The version of the database engine."
  default     = "15.8"
}
