output "consul_server_id" {
  value = aws_instance.consul_server.*.id
}

output "consul_server_private_ip" {
  value = aws_instance.consul_server.*.private_ip
}

# output "consul-servers-count" {
#   value = var.servers_count
# }
