# Start by explicitely defining state in a simple way, later we will turn this into a re-usable module


# Input Vars
variable "aws_region" {
  description = "AWS region ID for deployment (e.g. eu-west-1)"
  type        = string
}

variable "main_vpc_cidr" {
  description = "CIDR for the VPC (e.g. 10.0.0.0/16)"
  type        = string
  default = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR of the private subnet"
  type        = string
  default = "10.10.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR of the public subnet"
  type        = string
  default = "10.10.2.0/24"
}

# Configure AWS Provider
# Get access key and secret key from env.
provider "aws" {
  region = var.aws_region
}


# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.main_vpc_cidr
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = "true"
}

resource "aws_subnet" "private-subnet" {
  vpc_id     =  aws_vpc.main.id
  cidr_block = var.private_subnet_cidr
}

output "main_vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public-subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private-subnet.id
}