resource "aws_instance" "ec2_instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = var.key_name
  count                       = var.ec2_count
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  tags                        = var.tags

  provisioner "file" {
    source      = "D:\\terraform\\private-key\\jenkins_ec2_key"
    destination = "/home/ec2-user/jenkins_kp.pem"
    connection {
      user        = "ec2-user"
      type        = "ssh"
      private_key = file("D:\\terraform\\private-key\\homwork.pem")
      host        = self.public_ip
    }
  }
  provisioner "file" {
    source      = "D:\\terraform\\private-key\\homwork.pem"
    destination = "/home/ec2-user/homwork"
    connection {
      user        = "ec2-user"
      type        = "ssh"
      private_key = file("D:\\terraform\\private-key\\homwork.pem")
      host        = self.public_ip
    }
  }
  provisioner "file" {
    source      = "D:\\terraform\\private-key\\Consul_Private_Key.pem"
    destination = "/home/ec2-user/Consul_Private_Key.pem"
    connection {
      user        = "ec2-user"
      type        = "ssh"
      private_key = file("D:\\terraform\\private-key\\homwork.pem")
      host        = self.public_ip
    }
  }
}

