
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
/*
resource "aws_subnet" "public-subnet-a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_a_cidr
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[0]
}
*/

resource "aws_subnet" "private-subnet-a" {
  vpc_id     =  aws_vpc.main.id
  cidr_block = var.private_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
}

/*
resource "aws_subnet" "public-subnet-b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_b_cidr
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[1]
}
*/

resource "aws_subnet" "private-subnet-b" {
  vpc_id     =  aws_vpc.main.id
  cidr_block = var.private_subnet_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
}

/** NLB SETUP **/

# Setup an NLB for the API GW to make calls to EKS
resource "aws_lb" "microservices-lb" {
  name               = "microservices-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "microservices-target-group" {
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.main.id}"
}

resource "aws_lb_listener" "ms-lb-listener" {
  load_balancer_arn = "${aws_lb.microservices-lb.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.microservices-target-group.arn}"
  }
}

/** API GW SETUP **/

# Setup the API GW

resource "aws_api_gateway_vpc_link" "ms-vpc-link" {
  name        = "ms-vpc-link"
  description = "example description"
  target_arns = ["${aws_lb.microservices-lb.arn}"]
}


resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "This is my API for demonstration purposes"
}

/*
// Don't need this until later when we setup an actual API and connect it to the MS
resource "aws_api_gateway_resource" "MyDemoResource" {
  rest_api_id = "aws_api_gateway_rest_api.MyDemoAPI.id"
  parent_id   = "aws_api_gateway_rest_api.MyDemoAPI.root_resource_id"
  path_part   = "mydemoresource"
}
*/

/** k8 SETUP **/

// EKS Service IAM Role
resource "aws_iam_role" "ms-node" {
  name = "eks-cluster-ms"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ms-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.ms-node.name}"
}

resource "aws_iam_role_policy_attachment" "ms-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.ms-node.name}"
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.ms-node.arn

  vpc_config {
    subnet_ids         = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.ms-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.ms-AmazonEKSServicePolicy,
  ]
}
