output "ec2_instance_id" {
  value = aws_instance.ec2_instance.*.id
}

output "ec2_instance_private_ip" {
  value = aws_instance.ec2_instance.*.private_ip
}

output "ec2_instance_public_ip" {
  value = aws_instance.ec2_instance.*.public_ip
}

# output "aws_instance_public_dns"{
#     value = aws_instace.ec2_instance.public_dns
# }