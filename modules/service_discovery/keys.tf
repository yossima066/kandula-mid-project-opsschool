resource "tls_private_key" "key_consul_server" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_consul_server" {
  key_name   = "key_consul_server"
  public_key = tls_private_key.key_consul_server.public_key_openssh
}

resource "local_file" "key_consul_server" {
  sensitive_content = tls_private_key.key_consul_server.private_key_pem
  filename          = var.private_key_file
}
