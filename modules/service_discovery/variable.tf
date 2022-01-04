variable "region" {
  description = "AWS region for consul"
  default     = "us-east-1"
}

variable "ami" {
  description = "ami (ubuntu 18) to use - based on region"
  default = {
    "us-east-1" = "ami-00ddb0e5626798373"
    "us-east-2" = "ami-0dd9f0e7df0f0a138"
  }
}

# variable "vpc_cidr_block" {
#   type = list(string)
# }

variable "subnet_id" {
  type = list(string)

}

variable "private_key_file" {
  type        = string
  description = "Private Key File Path"
  default     = "D:\\terraform\\private-key\\Consul_Key.pem"
}

variable "consul_version" {
  type        = string
  description = "consul version"
  default     = "1.8.5"
}

variable "consul_dc_name" {
  type        = string
  description = "consul datacenter name"
  default     = "yossi"
}

variable "consul_server_name" {
  type        = string
  description = "consul server name"
  default     = "yossi-server"
}

variable "consul_agent_name" {
  type        = string
  description = "consul agent name"
  default     = "yossi-agent"
}

variable "servers_count" {
  type        = number
  description = "Number of servers to create"
  default     = 3
}
variable "agents_count" {
  type        = number
  description = "Number of agents to create"
  default     = 1
}

variable "vpc_id" {
  description = "VPC Name"
  type        = string
}
