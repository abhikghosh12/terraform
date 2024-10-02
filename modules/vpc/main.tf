# modules/vpc/main.tf

data "aws_availability_zones" "available" {
  state = "available"
}

# Check for existing VPC
data "aws_vpc" "existing" {
  count = 1
  tags = {
    Name = "${var.environment}-vpc"
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
  count             = var.az_count - length(data.aws_subnet.private)
  vpc_id            = local.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

# Create public subnets only if they don't exist
resource "aws_subnet" "public" {
  count                   = var.az_count - length(data.aws_subnet.public)
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

# Check for existing EIPs
data "aws_eip" "existing" {
  count = var.az_count
  tags = {
    Name        = "${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
    Purpose     = "NAT"
  }
}

# Create new EIPs only if necessary
resource "aws_eip" "nat" {
  count  = var.az_count - length(data.aws_eip.existing)
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip-${length(data.aws_eip.existing) + count.index + 1}"
    Environment = var.environment
    Purpose     = "NAT"
  }

  lifecycle {
    prevent_destroy = true
  }
}

locals {
  eip_ids = concat(
    [for eip in data.aws_eip.existing : eip.id],
    aws_eip.nat[*].id
  )
}

# Check for existing NAT Gateways
data "aws_nat_gateway" "existing" {
  count     = var.az_count
  subnet_id = length(data.aws_subnet.public) > count.index ? data.aws_subnet.public[count.index].id : aws_subnet.public[count.index].id
}

# Create NAT Gateways only if they don't exist
resource "aws_nat_gateway" "main" {
  count         = var.az_count - length(data.aws_nat_gateway.existing)
  allocation_id = local.eip_ids[count.index]
  subnet_id     = length(data.aws_subnet.public) > count.index ? data.aws_subnet.public[count.index].id : aws_subnet.public[count.index].id

  tags = {
    Name = "${var.environment}-nat-gw-${count.index + 1}"
  }
}

# Route Tables and Associations remain mostly unchanged
# ... (previous route table and association resources)

output "vpc_id" {
  value = local.vpc_id
}

output "private_subnet_ids" {
  value = concat(data.aws_subnet.private[*].id, aws_subnet.private[*].id)
}

output "public_subnet_ids" {
  value = concat(data.aws_subnet.public[*].id, aws_subnet.public[*].id)
}