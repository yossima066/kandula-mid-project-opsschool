output "jenkins_arns" {
  value = aws_instance.jenkins_agent.arn
}
output "jenkins_role_arn" {
  value = aws_iam_role.jenkins-role.arn
}

output "jenkins_nodes_ids" {
  description = "ARN of the Jenkins Nodes Instances"
  value       = aws_instance.jenkins_agent.id
}

# output "consul-servers-count" {
#   value = var.servers_count
# }

