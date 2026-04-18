output "alb_dns_name" {
  value = aws_lb.a4l_wordpress_alb.dns_name
}

output "wordpress_url" {
  value = "http://${aws_lb.a4l_wordpress_alb.dns_name}"
}

output "rds_endpoint" {
  value = aws_db_instance.wordpress_db.address
}

output "efs_file_system_id" {
  value = aws_efs_file_system.a4l_wordpress_content.id
}

output "asg_name" {
  value = aws_autoscaling_group.wordpress_asg.name
}
