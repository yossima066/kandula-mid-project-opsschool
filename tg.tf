# # module "nginx-tg" {
# #   source   = "/modules/target-groups"
# #   name     = "nginx-tg"
# #   port     = 80
# #   protocol = "HTTP"
# #   vpc_id   = module.main_vpc.aws_vpc_id
# # }

# Consul

module "consul-tg" {
  source               = "./modules/target-groups"
  name                 = "consul-tg"
  port                 = 8500
  protocol             = "HTTP"
  vpc_id               = module.main_vpc.aws_vpc_id
  health_check_path    = "/"
  health_check_port    = 8500
  health_check_matcher = 301

}

module "listener-lb" {
  source            = "./modules/lb-listeners"
  load_balancer_arn = module.lb.lb-arn
  port              = "80"
  protocol          = "HTTP"
  target_group_arn  = module.consul-tg.tg-arn
}


module "lb-tg-attachment-consul" {
  source           = "./modules/lb-tg-attachment"
  count            = length(module.monitoring.consul_server_id)
  target_group_arn = module.consul-tg.tg-arn
  target_id        = module.monitoring.consul_server_id[count.index]
  port             = 8500
  depends_on       = [module.monitoring]
}

# module "lb-tg-attachment-consul" {
#   source           = "./modules/lb-tg-attachment"
#   count            = length(module.consul.consul_server_id)
#   target_group_arn = module.consul-tg.tg-arn
#   target_id        = module.consul.consul_server_id[count.index]
#   port             = 8500
#   depends_on       = [module.consul]
# }




# Prometheus
module "prometheus-tg" {
  source               = "./modules/target-groups"
  name                 = "promcol"
  port                 = 9090
  protocol             = "HTTP"
  vpc_id               = module.main_vpc.aws_vpc_id
  health_check_path    = "/"
  health_check_port    = 9090
  health_check_matcher = 302

}

module "prometehus-listener-lb" {
  source            = "./modules/lb-listeners"
  load_balancer_arn = module.lb.lb-arn
  port              = "9090"
  protocol          = "HTTP"
  target_group_arn  = module.prometheus-tg.tg-arn
}


module "lb-tg-attachment-prometheus" {
  source           = "./modules/lb-tg-attachment"
  target_group_arn = module.prometheus-tg.tg-arn
  target_id        = module.monitoring.prometheus_server_id
  port             = 9090
  depends_on       = [module.monitoring]
}

# Grafana
module "grafana-tg" {
  source               = "./modules/target-groups"
  name                 = "Grafana"
  port                 = 3000
  protocol             = "HTTP"
  vpc_id               = module.main_vpc.aws_vpc_id
  health_check_path    = "/"
  health_check_port    = 3000
  health_check_matcher = 302

}

module "grafana-listener-lb" {
  source            = "./modules/lb-listeners"
  load_balancer_arn = module.lb.lb-arn
  port              = "3000"
  protocol          = "HTTP"
  target_group_arn  = module.grafana-tg.tg-arn
}


module "lb-tg-attachment-grafana" {
  source           = "./modules/lb-tg-attachment"
  target_group_arn = module.grafana-tg.tg-arn
  target_id        = module.monitoring.prometheus_server_id
  port             = 3000
  depends_on       = [module.monitoring]
}



# Elk

module "Elk-tg" {
  source               = "./modules/target-groups"
  name                 = "Elk"
  port                 = 5601
  protocol             = "HTTP"
  vpc_id               = module.main_vpc.aws_vpc_id
  health_check_path    = "/"
  health_check_port    = 5601
  health_check_matcher = 302

}

module "Elk-listener-lb" {
  source            = "./modules/lb-listeners"
  load_balancer_arn = module.lb.lb-arn
  port              = "5601"
  protocol          = "HTTP"
  target_group_arn  = module.Elk-tg.tg-arn
}


module "lb-tg-attachment-Elk" {
  source           = "./modules/lb-tg-attachment"
  target_group_arn = module.Elk-tg.tg-arn
  target_id        = module.Elk.elk_server_id
  port             = 5601
  depends_on       = [module.Elk]
}
