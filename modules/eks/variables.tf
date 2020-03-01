variable "aws_region" {
  description = "AWS region ID for deployment (e.g. eu-west-1)"
  type        = string
  default     = "eu-west-2"
}

variable "cluster-name" {  
  type        = string
}

variable "vpc-id" {  
  type        = string
}

variable "cluster-subnet-ids" {
  type = list(string)
}

variable "nodegroup-subnets-ids" {
  type = list(string)
}

