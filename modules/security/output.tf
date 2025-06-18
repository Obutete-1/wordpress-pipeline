output "ec2_sg_id" {
  description = "ID of EC2 security group"
  value       = aws_security_group.ec2.id
}

output "eic_sg_id" {
  description = "ID of EIC security group"
  value       = aws_security_group.eic.id
}

output "efs_sg_id" {
  description = "ID of EFS security group"
  value       = aws_security_group.efs.id
}

output "rds_sg_id" {
  description = "ID of RDS security group"
  value       = aws_security_group.rds.id
}

output "alb_sg_id" {
  description = "ID of ALB security group"
  value       = aws_security_group.alb.id
}
