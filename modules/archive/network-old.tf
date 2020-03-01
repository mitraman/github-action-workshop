
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


  // EKS/k8 requires us to add a kubernetes tag to VPC and subnet resources in order to make them discoverable
  tags = {
    "Name"                                      = "ms-up-running"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
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
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    "Name"                                      = "ms-up-running"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
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
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    "Name"                                      = "ms-up-running"
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

/** NLB SETUP **/

/*
# Setup an NLB for the API GW to make calls to EKS
resource "aws_lb" "microservices-lb" {
  name               = "microservices-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]
  enable_deletion_protection = false

  tags = {
     "Name"                                      = "ms-up-running"
   }
}

resource "aws_lb_target_group" "microservices-target-group" {
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.main.id}"

  tags = {
     "Name"                                      = "ms-up-running"
   }
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
*/

/** API GW SETUP **/

# Setup the API GW
/*
resource "aws_api_gateway_vpc_link" "ms-vpc-link" {
  name        = "ms-vpc-link"
  description = "example description"
  target_arns = ["${aws_lb.microservices-lb.arn}"]

  tags = {
     "Name"                                      = "ms-up-running"
   }
}


resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "This is my API for demonstration purposes"

  tags = {
     "Name"                                      = "ms-up-running"
   }
}
*/

/*
// Don't need this until later when we setup an actual API and connect it to the MS
resource "aws_api_gateway_resource" "MyDemoResource" {
  rest_api_id = "aws_api_gateway_rest_api.MyDemoAPI.id"
  parent_id   = "aws_api_gateway_rest_api.MyDemoAPI.root_resource_id"
  path_part   = "mydemoresource"
}
*/

/** EKS SETUP **/

// ** EKS Service IAM Role
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


// ** EKS Master Cluster
// NOTE: I haven't setup the security policy for this
resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.ms-node.arn

  vpc_config {
    subnet_ids              = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ms-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.ms-AmazonEKSServicePolicy,
  ]

  tags = {
    "Name" = "ms-up-running"
  }
}


// ** EKS Node groups for k8 pods
// Just use two node groups for now. Later we may need to fine tune this config as we build out the application properly

//TODO Fix names so they are not examples
resource "aws_iam_role" "eks-node-group-role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-group-role.name
}

resource "aws_eks_node_group" "ms-nodegroup" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "ms-nodegroup"
  node_role_arn   = aws_iam_role.eks-node-group-role.arn
  subnet_ids      = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    "Name"                                      = "ms-up-running"
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}