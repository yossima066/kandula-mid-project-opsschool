variable "aws_account_id" {
  type    = string
  default = "461307513197"
}


variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "aws_profile" {
  type    = string
  default = "opSschool"
}
variable "ssh_key_name" {
  default = "homwork"
  type    = string
}
variable "prefix_name" {
  default = "yossi"
  type    = string
}
variable "instance_count" {
  type    = number
  default = 1
}

variable "vpc_id" {
  type = string
}

variable "aws_subnet_ids" {
  type = list(string)
}

variable "default_sg" {

}
