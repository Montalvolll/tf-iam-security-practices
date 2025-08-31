# module "ip" {
#   source = "./modules/ip"

# }

module "vpc" {
  source = "./modules/vpc"

  tags = var.tags

}

module "s3" {
  source = "./modules/s3"

  s3_bucket_name = var.s3_bucket_name
  tags           = var.tags

}

module "ec2" {
  source = "./modules/ec2"

  instance_type             = var.instance_type
  my_ip                     = var.my_ip
  vpc_id                    = module.vpc.vpc_id
  public_1_subnet_id        = module.vpc.public_1_subnet_id
  ec2_instance_profile_name = module.iam.ec2_instance_profile_name

  tags = var.tags
}

module "rds" {
  source = "./modules/rds"

  db_identifier       = var.db_identifier
  db_username         = var.db_username
  db_name             = var.db_name
  db_password         = module.rds.db_password
  db_instance_class   = var.db_instance_class
  db_engine_version   = var.db_engine_version
  sg_from_ec2_id      = module.ec2.security_group_id
  private_1_subnet_id = module.vpc.private_1_subnet_id
  private_2_subnet_id = module.vpc.private_2_subnet_id
  vpc_id              = module.vpc.vpc_id

  tags = var.tags
}

module "iam" {
  source = "./modules/iam"

  instance_arn = module.ec2.instance_arn
  rds_arn      = module.rds.rds_arn
  bucket_arn   = module.s3.bucket_arn
  bucket_name  = module.s3.bucket_id
  tags         = var.tags
}
