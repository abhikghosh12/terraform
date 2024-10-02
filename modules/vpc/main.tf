# modules/vpc/main.tf

data "aws_availability_zones" "available" {
  state = "available"
}

# Check for existing VPC with a more specific filter
data "aws_vpc" "existing" {
  count = 1
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-vpc"]
  }
  filter {
    name   = "cidr-block"
    values = [var.vpc_cidr]
  }
}

locals {
  vpc_id = length(data.aws_vpc.existing) > 0 ? data.aws_vpc.existing[0].id : aws_vpc.main[0].id
}

# Create VPC only if it doesn't exist
resource "aws_vpc" "main" {
  count                = length(data.aws_vpc.existing) == 0 ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Check for existing subnets
data "aws_subnet" "private" {
  count  = var.az_count
  vpc_id = local.vpc_id
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-private-subnet-${count.index + 1}"]
  }
}

data "aws_subnet" "public" {
  count  = var.az_count
  vpc_id = local.vpc_id
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-public-subnet-${count.index + 1}"]
  }
}

# Create private subnets only if they don't exist
resource "aws_subnet" "private" {
  count             = var.az_count - length([for s in data.aws_subnet.private : s.id if s.id != ""])
  vpc_id            = local.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

# Create public subnets only if they don't exist
resource "aws_subnet" "public" {
  count                   = var.az_count - length([for s in data.aws_subnet.public : s.id if s.id != ""])
  vpc_id                  = local.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

# Check for existing Internet Gateway
data "aws_internet_gateway" "existing" {
  count = 1
  filter {
    name   = "attachment.vpc-id"
    values = [local.vpc_id]
  }
}

# Create Internet Gateway only if it doesn't exist
resource "aws_internet_gateway" "main" {
  count  = length(data.aws_internet_gateway.existing) == 0 ? 1 : 0
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# Create new EIPs only if necessary
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? var.az_count : 0
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
    Purpose     = "NAT"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create NAT Gateways only if specified
resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gateway ? var.az_count : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = length([for s in data.aws_subnet.public : s.id if s.id != ""]) > count.index ? data.aws_subnet.public[count.index].id : aws_subnet.public[count.index].id

  tags = {
    Name = "${var.environment}-nat-gw-${count.index + 1}"
  }
}

# Route table for private subnets
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.environment}-private-route-table-${count.index + 1}"
  }
}

# Route for private subnets
resource "aws_route" "private_nat_gateway" {
  count                  = var.create_nat_gateway ? var.az_count : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

# Route for public subnets
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = length(data.aws_internet_gateway.existing) > 0 ? data.aws_internet_gateway.existing[0].id : aws_internet_gateway.main[0].id
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = length([for s in data.aws_subnet.private : s.id if s.id != ""]) > count.index ? data.aws_subnet.private[count.index].id : aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = length([for s in data.aws_subnet.public : s.id if s.id != ""]) > count.index ? data.aws_subnet.public[count.index].id : aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

output "vpc_id" {
  value = local.vpc_id
}

output "private_subnet_ids" {
  value = concat([for s in data.aws_subnet.private : s.id if s.id != ""], aws_subnet.private[*].id)
}

output "public_subnet_ids" {
  value = concat([for s in data.aws_subnet.public : s.id if s.id != ""], aws_subnet.public[*].id)
}