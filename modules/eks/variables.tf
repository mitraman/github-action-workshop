# Input Vars
variable "aws_region" {
  description = "AWS region ID for deployment (e.g. eu-west-1)"
  type        = string
  default     = "eu-west-2"
}

# EKS Vars
variable "cluster-name" {  
  type        = string
  default = "example-cluster"
}
