provider "aws" {
  region = var.region
}

resource "aws_security_group" "consul" {
  name        = "consul-opsschool"
  description = "Allow ssh & consul control"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh "
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow consul ui "
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outside security"
  }

}

# Create an IAM role for auto login

resource "aws_iam_role" "consul-join" {
  name               = "consul-oppschool-join"
  assume_role_policy = file("${path.module}/templates/polices/assume-role.json")
}
#  create policy
resource "aws_iam_policy" "consul-join" {
  name        = "consul-oppschool-join"
  description = "Allows consul nodes to describe instance for joining"
  policy      = file("${path.module}/templates/polices/describe-instances.json")

}

# Attach policy to role

resource "aws_iam_policy_attachment" "consul-join" {
  name       = "consul-oppschool-join"
  roles      = [aws_iam_role.consul-join.name]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create instance profile 

resource "aws_iam_instance_profile" "consul-join" {
  name = "consul-oppschool-join"
  role = aws_iam_role.consul-join.name
}
