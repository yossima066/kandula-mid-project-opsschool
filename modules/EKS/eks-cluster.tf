module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnets         = var.private_subnets

  enable_irsa = true

  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = var.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t3.large"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    }
  ]
  map_users = [{
    userarn  = module.jenkins.jenkins_arns
    username = module.Jenkins.jenkins_nodes_ids
    groups   = ["system:masters"]
    }
  ]

  map_roles = [
    {
      rolearn  = module.main_vpc.aws_vpc_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:masters"]
    }
  ]
  manage_aws_auth = true
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}
