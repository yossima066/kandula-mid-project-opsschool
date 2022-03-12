# # module "nginx-tg" {
# #   source   = "/modules/target-groups"
# #   name     = "nginx-tg"
# #   port     = 80
# #   protocol = "HTTP"
# #   vpc_id   = module.main_vpc.aws_vpc_id
# # }

module "consul-tg" {
  source   = "./modules/target-groups"
  name     = "consul-tg"
  port     = 8500
  protocol = "HTTP"
  vpc_id   = module.main_vpc.aws_vpc_id
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





