module "nginx-sg" {
  source      = "./\\modules\\security-group"
  name        = "nginx-server-sg"
  description = "allow ssh,http"
  vpc_id      = module.main_vpc.aws_vpc_id
  tags = {
    Name    = "allow_http-ssh",
    Owner   = "yossi",
    Purpuse = "SG for NGINX"
  }
}
module "sg-rule-in-1" {
  source            = "./\\modules\\security-group-rule"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.nginx-sg.aws_security_group_id
}

module "sg-rule-in-2" {
  source            = "./\\modules\\security-group-rule"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.nginx-sg.aws_security_group_id
}

module "sg-rule-out" {
  source            = "./\\modules\\security-group-rule"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.nginx-sg.aws_security_group_id
}


module "bastion-sg" {
  source      = "./\\modules\\security-group"
  name        = "bastion-host-sg"
  description = "allow ssh"
  vpc_id      = module.main_vpc.aws_vpc_id
  tags = {
    Name    = "allow-ssh",
    Owner   = "yossi",
    Purpuse = "SG for bastion"
  }
}
module "bastion-sg-rule-out" {
  source            = "./\\modules\\security-group-rule"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion-sg.aws_security_group_id
}
module "bastion-sg-rule-in-ssh" {
  source            = "./\\modules\\security-group-rule"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion-sg.aws_security_group_id
}
