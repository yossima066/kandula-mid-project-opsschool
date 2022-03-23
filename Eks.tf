module "eks" {
  source                   = ".\\modules\\EKS"
  vpc_id                   = module.main_vpc.aws_vpc_id
  private_subnets          = [module.private_subnet_1.aws_subnet_id, module.private_subnet_2.aws_subnet_id]
  consul_security_group_id = module.monitoring.security_group_consul
  # jenkins_role = module.ci-cd.jenkins_role_arn
}
