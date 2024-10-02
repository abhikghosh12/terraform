# modules/vpc/main.tf

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# Check for existing EIPs
data "aws_eips" "existing" {
  tags = {
    Environment = var.environment
    Purpose     = "NAT"
  }
}

locals {
  existing_eip_count = length(data.aws_eips.existing.allocation_ids)
  eips_to_create     = min(var.az_count - local.existing_eip_count, 1)  # Create at most 1 new EIP
}

# Create new EIP only if necessary
resource "aws_eip" "nat" {
  count  = local.eips_to_create
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip-${local.existing_eip_count + 1}"
    Environment = var.environment
    Purpose     = "NAT"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Combine existing and new EIPs
locals {
  all_eip_ids = concat(data.aws_eips.existing.allocation_ids, aws_eip.nat[*].id)
}

resource "aws_nat_gateway" "main" {
  count         = min(length(local.all_eip_ids), 1)  # Create at most 1 NAT Gateway
  allocation_id = local.all_eip_ids[count.index]
  subnet_id     = aws_subnet.public[0].id  # Always use the first public subnet

  tags = {
    Name = "${var.environment}-nat-gw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = {
    Name = "${var.environment}-private-route-table"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-public-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}