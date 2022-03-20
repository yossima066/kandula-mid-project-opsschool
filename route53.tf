module "route53" {
  source            = ".\\modules\\route53"
  vpc_id            = module.main_vpc.aws_vpc_id
  elk_ip            = module.Elk.public_ip
  jenkins_agent     = module.jenkins.jenkins_agent_ip
  jenkins_server    = module.jenkins.jenkins_server_ip
  promcol_prv_ip    = module.monitoring.promcol_prv_ip
  consul_client_ip  = module.monitoring.clients_prv
  consul_servers_ip = module.monitoring.servers_prv
}
