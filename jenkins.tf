module "jenkins" {
  source        = ".\\modules\\ci-cd"
  master_subnet = module.public_subnet_1.aws_subnet_id
  agents_subnet = module.private_subnet_1.aws_subnet_id
  vpc_id        = module.main_vpc.aws_vpc_id
  default_sg    = module.main_vpc.default_sg_id
}
