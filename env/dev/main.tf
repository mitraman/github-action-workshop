

module "aws-network" {
    source = "../../modules/network"

    aws_region = "eu-west-2"
    main_vpc_cidr = "10.10.0.0/16"
    public_subnet_a_cidr = "10.10.0.0/18"
    public_subnet_b_cidr = "10.10.64.0/18"
    private_subnet_a_cidr = "10.10.128.0/18"
    private_subnet_b_cidr = "10.10.192.0/18"
}

module "aws-kubernetes-cluster" {
    source = "../../modules/eks"

    aws_region = "eu-west-2"
    cluster-name = "ms-up-running"
    vpc-id = module.aws-network.vpc-id
    cluster-subnet-ids = module.aws-network.subnet-ids
    nodegroup-subnets-ids = module.aws-network.private-subnet-ids
}