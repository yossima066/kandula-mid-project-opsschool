provider "aws" {
  region = "us-east-1"
}

locals {
  jenkins_default_name = "jenkins"
  jenkins_home         = "/home/ubuntu/jenkins_home"
  jenkins_home_mount   = "${local.jenkins_home}:/var/jenkins_home"
  docker_sock_mount    = "/var/run/docker.sock:/var/run/docker.sock"
  java_opts            = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"
}

data "aws_ami" "jenkins_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["jenkins-ami-latest"]
  }
}
resource "aws_iam_role" "jenkins-role" {
  name = "jekins-role"
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
    Name = "jenkins-role"
  }
}
resource "aws_iam_policy" "jenkins-policy" {
  name = "jenkins-policy"
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
resource "aws_iam_role_policy_attachment" "jenkins-policy-role" {
  role       = aws_iam_role.jenkins-role.name
  policy_arn = aws_iam_policy.jenkins-policy.arn
}
resource "aws_iam_instance_profile" "jenkins-profile" {
  name = "jenkins-profile"
  role = aws_iam_role.jenkins-role.name
}




resource "aws_security_group" "jenkins" {
  name        = local.jenkins_default_name
  description = "Allow Jenkins inbound traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  ingress {
    from_port = 9200
    to_port   = 9200
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port = 8500
    to_port   = 8500
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = local.jenkins_default_name
  }
}

resource "aws_instance" "jenkins_server" {
  ami                  = data.aws_ami.jenkins_ami.id
  count                = var.clients
  instance_type        = "t3.micro"
  subnet_id            = var.master_subnet
  key_name             = "jenkins_ec2_key"
  iam_instance_profile = aws_iam_instance_profile.jenkins-profile.name
  # user_data            = file("${path.module}/jenkinsserver.sh")
  user_data = element(data.template_cloudinit_config.consul_client.*.rendered, count.index)
  tags = {
    Name = "Jenkins Server"
  }
  connection {
    host        = self.public_ip
    user        = "ubuntu"
    type        = "ssh"
    private_key = file("${var.key_file}")
  }
  vpc_security_group_ids = [
    var.default_sg,
    aws_security_group.jenkins.id

  ]
}

data "template_file" "consul_client" {
  count    = var.clients
  template = file("${path.module}/templates/consul.sh.tpl")

  vars = {
    consul_version        = var.consul_version
    node_exporter_version = var.node_exporter_version
    prometheus_dir        = var.prometheus_dir
    config                = <<EOF
       "node_name": "jenkins-${count.index + 1}",
       "enable_script_checks": true,
       "server": false
      EOF
  }
}

data "template_cloudinit_config" "consul_client" {
  count = var.clients
  part {
    content = element(data.template_file.consul_client.*.rendered, count.index)

  }
  part {
    content = element(data.template_file.webserver.*.rendered, count.index)
  }
}

data "template_file" "webserver" {
  count    = var.clients
  template = file("${path.module}/templates/webserver.sh.tpl")

  vars = {
    apache_exporter_version = var.apache_exporter_version
    prometheus_dir          = var.prometheus_dir

  }
}

resource "aws_instance" "jenkins_agent" {
  #ami                  = "ami-089f02765b2624c7b"
  ami                  = "ami-0275ae2b090744e24"
  instance_type        = "t3.micro"
  subnet_id            = var.agents_subnet
  user_data            = file("${path.module}/userdata.sh")
  key_name             = "jenkins_ec2_key"
  iam_instance_profile = aws_iam_instance_profile.jenkins-profile.name


  tags = {
    Name = "Jenkins Agent"
  }

  vpc_security_group_ids = [
    var.default_sg,
    aws_security_group.jenkins.id,

  ]
}
