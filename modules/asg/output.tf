output "asg_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.id
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.main.id
}

output "asg_instance_id" {
  description = "ASG Instance Id"
  value       = data.aws_instances.asg_instances.ids
}
