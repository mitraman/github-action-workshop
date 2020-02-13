
# Configure AWS Provider
# Get access key and secret key from env.
provider "aws" {
  region = var.aws_region
}

# This terraform data source will provide us with a list of AWS availability zones within
# the region that has been selected
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.main_vpc_cidr
}

# We need to define two availability zones for EKS

# We will create a pair of public and private subnets in each availability zone
resource "aws_subnet" "public-subnet-a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "private-subnet-a" {
  vpc_id     =  aws_vpc.main.id
  cidr_block = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "public-subnet-b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_subnet" "private-subnet-b" {
  vpc_id     =  aws_vpc.main.id
  cidr_block = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
}
