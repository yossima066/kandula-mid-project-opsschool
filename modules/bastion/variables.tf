variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "ec2_count" {
  type    = number
  default = 1
}
variable "key_name" {
  type = string
}
variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(any)
}
