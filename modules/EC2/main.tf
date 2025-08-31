variable "tags" { type = map(string) }
variable "vpc_id" { type = string }
variable "my_ip" { type = string }
variable "instance_type" { type = string }
variable "public_1_subnet_id" { type = string }
variable "ec2_instance_profile_name" { type = string }

# Generate a private key 
resource "tls_private_key" "kp" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a key pair using the generated private key
resource "aws_key_pair" "kp" {
  key_name   = "playground-key-pair"
  public_key = tls_private_key.kp.public_key_openssh
}

resource "local_file" "playground_key" {
  content         = tls_private_key.kp.private_key_pem
  filename        = "${path.module}/playground-key.pem"
  file_permission = "0600"

}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH traffic from my IP and HTTP from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Allow http traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow engress traffic from anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "web_app" {
  ami                    = data.aws_ami.amazon_linux2.id # Standard Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type          = var.instance_type
  subnet_id              = var.public_1_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  monitoring             = true
  ebs_optimized          = true
  key_name               = aws_key_pair.kp.key_name
  iam_instance_profile   = var.ec2_instance_profile_name

  user_data = <<-EOT
              #!/bin/bash
              yum update -y
              sudo yum install aws-cli -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo '<h1>Hello from EC2 (HTTP 80)</h1>' > /var/www/html/index.html
              EOT

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  tags = {
    Name = "myplayground-ec2-instance"
  }

}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-*-x86_64*"] # Standard Amazon Linux 2 AMI (HVM), SSD Volume Type
  }
}

output "public_ip" { value = aws_instance.web_app.public_ip }
output "security_group_id" { value = aws_security_group.ec2_sg.id }
output "instance_arn" { value = aws_instance.web_app.arn }
