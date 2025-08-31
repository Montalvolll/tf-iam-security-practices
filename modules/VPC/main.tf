variable "tags" { type = map(string) }

# This is to have at least two usable AZs
data "aws_availability_zones" "usable" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.this.id

  tags = var.tags
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.usable.names[0]
  tags              = var.tags
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.usable.names[1]
  tags              = var.tags
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.vpc_igw]

  tags = var.tags

}

resource "aws_route_table" "public_1" {
  vpc_id = aws_vpc.this.id

}

resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_1.id

}

resource "aws_route" "public_1_internet_access" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public_1.id
  gateway_id             = aws_internet_gateway.vpc_igw.id

}

output "vpc_id" { value = aws_vpc.this.id }
output "public_1_subnet_id" { value = aws_subnet.public_1.id }
output "private_1_subnet_id" { value = aws_subnet.private_1.id }
output "private_2_subnet_id" { value = aws_subnet.private_2.id }

