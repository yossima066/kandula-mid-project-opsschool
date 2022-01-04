resource "aws_instance" "consul_server" {
  count                  = var.servers_count
  ami                    = lookup(var.ami, var.region)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_consul_server.key_name
  subnet_id              = element(var.subnet_id, count.index)
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.consul.id]
  user_data              = data.template_file.consul_server.*.rendered[count.index]

  tags = {
    Name          = "consul-server-${count.index + 1}"
    consul_server = "true"
  }
}

resource "aws_instance" "consul_agent" {
  count                  = var.agents_count
  ami                    = lookup(var.ami, var.region)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_consul_server.key_name
  subnet_id              = element(var.subnet_id, count.index)
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.consul.id]
  user_data              = data.template_file.consul_agent.*.rendered[count.index]

  tags = {
    Name = "consul-agent-${count.index + 1}"
  }
}

data "template_file" "consul_server" {
  count    = var.servers_count
  template = file("${path.module}/templates/server.tpl")
  vars = {
    consul_version     = var.consul_version
    consul_dc_name     = var.consul_dc_name
    consul_server_name = "${var.consul_server_name}-${count.index}"
    servers_count      = var.servers_count
  }
}

data "template_file" "consul_agent" {
  count    = var.agents_count
  template = file("${path.module}/templates/agent.tpl")
  vars = {
    consul_version    = var.consul_version
    consul_dc_name    = var.consul_dc_name
    consul_agent_name = "${var.consul_agent_name}-${count.index}"
  }
}

# output "server" {
#   value = aws_instance.consul_server.*.public_ip
# }

# output "agent" {
#   value = aws_instance.consul_agent.*.public_ip
# }

