resource "aws_ssm_parameter" "db_user" {
  name        = "/A4L/Wordpress/DBUser"
  description = "Wordpress Database User"
  type        = "String"
  value       = var.db_user
}

resource "aws_ssm_parameter" "db_name" {
  name        = "/A4L/Wordpress/DBName"
  description = "Wordpress Database Name"
  type        = "String"
  value       = var.db_name
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/A4L/Wordpress/DBPassword"
  description = "Wordpress DB Password"
  type        = "SecureString"
  value       = var.db_password
  key_id      = "alias/aws/ssm"
}

resource "aws_ssm_parameter" "db_endpoint" {
  name        = "/A4L/Wordpress/DBEndpoint"
  description = "Wordpress DB Endpoint Name"
  type        = "String"
  value       = aws_db_instance.wordpress_db.address
}

resource "aws_ssm_parameter" "file_system_id" {
  name        = "/A4L/Wordpress/EFSFSID"
  description = "File System ID for Wordpress Content (wp-content)"
  type        = "String"
  value       = aws_efs_file_system.a4l_wordpress_content.id
}

resource "aws_ssm_parameter" "alb_dns_name" {
  name        = "/A4L/Wordpress/ALBDNSNAME"
  description = "DNS Name of the Application Load Balancer for wordpress"
  type        = "String"
  value       = aws_lb.a4l_wordpress_alb.dns_name
}
