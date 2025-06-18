output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.wordpress.id
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.wordpress.private_ip
}

output "account_id" {
  description = "Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "ami_id" {
  description = "AMI ID"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "iam_instance_profile" {
  description = "IAM EC2 Profile"
  value       = aws_iam_instance_profile.wordpress_profile.name
}
