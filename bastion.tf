module "bastion" {
  source                 = "./modules/bastion"
  ami                    = "ami-033b95fb8079dc481"
  instance_type          = "t2.micro"
  key_name               = "homwork"
  vpc_id                 = module.main_vpc.aws_vpc_id
  vpc_security_group_ids = [module.bastion-sg.aws_security_group_id]
  subnet_id              = module.public_subnet_2.aws_subnet_id
  tags = {
    Name = "bastion-server"
  }
}
