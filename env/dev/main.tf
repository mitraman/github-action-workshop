

module "aws-network" {
    source = "../../modules/network"

    vpc_name = "microservices-up-running"
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
    cluster_name = "ms-up-running"
    vpc_id = module.aws-network.vpc-id
    cluster_subnet_ids = module.aws-network.subnet-ids
        
    nodegroup_subnets_ids = module.aws-network.private-subnet-ids
    nodegroup_disk_size = "20"
    nodegroup_instance_types = ["t3.medium"]
    nodegroup_desired_size = 1
    nodegroup_min_size = 1
    nodegroup_max_size = 1
}