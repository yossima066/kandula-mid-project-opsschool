module "Elk" {
  source         = ".\\modules\\Elk"
  vpc_id         = module.main_vpc.aws_vpc_id
  aws_subnet_ids = [module.public_subnet_1.aws_subnet_id]
  default_sg     = module.monitoring.security_group_consul
}
