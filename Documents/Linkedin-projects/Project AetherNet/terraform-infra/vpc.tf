# AetherNet VPC, Subnets, Internet Gateway & Route Tables Manifest

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-101010"
    Project     = "AetherNet"
    ManagedBy   = "Terraform"
    Author      = "Aakash Pandian"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "aethernet-igw"
    Project   = "AetherNet"
    Author    = "Aakash Pandian"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name    = "aethernet-public-subnet"
    Tier    = "Public"
    Author  = "Aakash Pandian"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_region}b"

  tags = {
    Name    = "aethernet-private-subnet"
    Tier    = "Private"
    Author  = "Aakash Pandian"
  }
}

# Public Route Table (Bound to IGW for authorized public traffic)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name   = "aethernet-public-rt"
    Author = "Aakash Pandian"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Isolated Private Route Table (Strict Zero-Trust Perimeter - NO 0.0.0.0/0 routes permitted)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "rtb-9e353773"
    Alias   = "aethernet-private-rt"
    Author  = "Aakash Pandian"
    Security = "ZeroTrustPerimeter"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}
