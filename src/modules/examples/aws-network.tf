# Need to specify a backend like s3 for terraform state

# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-2"
  # Need to change the auth method so we are not hardcoding secrets. Have to implement Vault or use env vars.
  access_key = "AKIA4IGBHKZTFKQK6Q4L"
  secret_key = "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"
}

# Create a simple VPC
# Need to update this to make sure it is suitable for the rest of the MS Build
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Setup IAM for EKS
resource "aws_iam_group" "eks_group" {
  name = "k8"  
}

resource "aws_iam_user" "eks_user" {
  name = "k8"  
}

resource "aws_iam_user_group_membership" "eks_user_group" {
  user = "${aws_iam_user.eks_user.name}"

  groups = [
    "${aws_iam_group.eks_group.name}"
  ]
}

/*
# Attach policy to our EKS group
resource "aws_iam_group_policy_attachment" "test-attach" {
  group      = "${aws_iam_group.eks_group.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}
*/

/*
resource "aws_eks_cluster" "example" {
  name     = "example"
  role_arn = "${aws_iam_role.example.arn}"

  vpc_config {
    subnet_ids = ["${aws_subnet.example1.id}", "${aws_subnet.example2.id}"]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    "aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.example-AmazonEKSServicePolicy",
  ]
}
*/