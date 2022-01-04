variable "master_subnet" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "agents_subnet" {
  type = string
}

variable "default_sg" {
  type = string

}

variable "key_file" {
  type    = string
  default = "D:\\terraform\\private-key\\jenkins_ec2_key"
}
