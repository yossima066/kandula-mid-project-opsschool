output "consul_server_id" {
  value = aws_instance.consul_server.*.id
}

output "consul_server_private_ip" {
  value = aws_instance.consul_server.*.private_ip
}

output "security_group_consul" {
  value = aws_security_group.opsschool_consul.id
}


output "servers_prv" {
  value = aws_instance.consul_server.*.private_ip
}

output "clients_prv" {
  value = aws_instance.consul_client.*.private_ip
}
