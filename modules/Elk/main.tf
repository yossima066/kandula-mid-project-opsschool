# ---------------------------------------------------------------------------------------------------------------------
# data
# ---------------------------------------------------------------------------------------------------------------------
# get default vpc id

# get latest ubuntu 18 ami
data "aws_ami" "ami" {
  owners      = ["099720109477"] # canonical
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# get my external ip
data "http" "myip" {
  url = "http://ifconfig.me"
}

# ---------------------------------------------------------------------------------------------------------------------
# security group
# ---------------------------------------------------------------------------------------------------------------------
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  name   = "${var.prefix_name}-elk"
  vpc_id = var.vpc_id

  ingress_cidr_blocks = ["${data.http.myip.body}/32"]
  ingress_rules = [
    "elasticsearch-rest-tcp",
    "elasticsearch-java-tcp",
    "kibana-tcp",
    "logstash-tcp",
    "ssh-tcp"
  ]
  ingress_with_self = [{ rule = "all-all" }]
  egress_rules      = ["all-all"]

}

# ---------------------------------------------------------------------------------------------------------------------
# ec2
# ---------------------------------------------------------------------------------------------------------------------
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.16.0"

  instance_count              = var.instance_count
  name                        = "${var.prefix_name}-elk"
  instance_type               = "t3.medium"
  ami                         = data.aws_ami.ami.id
  key_name                    = var.ssh_key_name
  subnet_id                   = tolist(var.aws_subnet_ids)[0]
  vpc_security_group_ids      = [module.security-group.this_security_group_id, var.default_sg]
  iam_instance_profile        = aws_iam_instance_profile.elk-profile.name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


resource "aws_iam_role" "elk-role" {
  name = "elk-role"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "elk-role"
  }
}
resource "aws_iam_policy" "elk-policy" {
  name = "elk-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
          "ec2:Describe*",
          "sts:AssumeRole",
          "eks:DescribeCluster",
        "ec2:DescribeInstances"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]

  })
}
resource "aws_iam_role_policy_attachment" "elk-policy-role" {
  role       = aws_iam_role.elk-role.name
  policy_arn = aws_iam_policy.elk-policy.arn
}
resource "aws_iam_instance_profile" "elk-profile" {
  name = "elk-profile"
  role = aws_iam_role.elk-role.name
}



