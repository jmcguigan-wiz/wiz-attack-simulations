# Create VPC
resource "aws_vpc" "wiz_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "wiz_vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.wiz_vpc.id

  tags = {
    Name = "wiz_igw"
  }
}

# Create Public Subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.wiz_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a" # Replace with your desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

# Create Public Subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.wiz_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b" # Replace with your desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# Create Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.wiz_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Route Table with Public Subnet 1
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Route Table with Public Subnet 2
resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group allowing outbound traffic
resource "aws_security_group" "allow_wiz" {
  name        = "wiz-sg"
  description = "Allow outbound traffic"
  vpc_id      = aws_vpc.wiz_vpc.id

  # Add egress rule to allow all outbound traffic (important!)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_wiz"
  }
}