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