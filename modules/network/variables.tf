# Input Vars
variable "aws_region" {
  description = "AWS region ID for deployment (e.g. eu-west-1)"
  type        = string
  default     = "eu-west-2"
}

variable "main_vpc_cidr" {
  description = "CIDR for the VPC (e.g. 10.0.0.0/16)"
  type        = string
  default = "10.10.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR of the public subnet"
  type        = string
  default = "10.10.0.0/18"
}

variable "public_subnet_b_cidr" {
  description = "CIDR of the public subnet"
  type        = string
  default = "10.10.64.0/18"
}

variable "private_subnet_a_cidr" {
  description = "CIDR of the private subnet"
  type        = string
  default = "10.10.128.0/18"
}


variable "private_subnet_b_cidr" {
  description = "CIDR of the private subnet"
  type        = string
  default = "10.10.192.0/18"
}


# EKS Vars
variable "cluster-name" {  
  type        = string
  default = "example-cluster"
}
