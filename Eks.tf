module "eks" {
  source          = ".\\modules\\EKS"
  vpc_id          = module.main_vpc.aws_vpc_id
  private_subnets = [module.private_subnet_1.aws_subnet_id, module.private_subnet_2.aws_subnet_id]
  # jenkins_role = module.ci-cd.jenkins_role_arn
}
