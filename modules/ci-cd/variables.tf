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

variable "consul_version" {
  description = "The version of Consul to install (server and client)."
  default     = "1.4.0"
}



variable "prometheus_dir" {
  description = "directory for prometheus binaries"
  default     = "/opt/prometheus"
}

variable "clients" {
  description = "The number of consul client instances"
  default     = 1
}

variable "apache_exporter_version" {
  description = "Apache Exporter version"
  default     = "0.7.0"
}


variable "node_exporter_version" {
  description = "Node Exporter version"
  default     = "0.18.1"
}
