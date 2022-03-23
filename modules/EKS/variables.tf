variable "kubernetes_version" {
  default     = 1.21
  description = "kubernetes version"
}

variable "aws_region" {
  default     = "us-east-1"
  description = "aws region"
}

locals {
  k8s_service_account_namespace = "default"
  k8s_service_account_name      = "opsschool-sa"
  # jenkins_role = var.jenkins_role
}


variable "vpc_id" {
  default     = "us-east-1"
  description = "aws region"
}

variable "private_subnets" {
  type = list(string)

}


# variable "jenkins_role" {

# }

variable "consul_security_group_id" {
  description = "security group of consul"
  type        = string
}
