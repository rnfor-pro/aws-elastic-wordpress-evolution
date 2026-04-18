resource "aws_efs_file_system" "a4l_wordpress_content" {
  creation_token   = "A4L-WORDPRESS-CONTENT"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = false

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "A4L-WORDPRESS-CONTENT"
  }
}

resource "aws_efs_mount_target" "efs_mount_a" {
  file_system_id  = aws_efs_file_system.a4l_wordpress_content.id
  subnet_id       = aws_subnet.sn_app_a.id
  security_groups = [aws_security_group.sg_efs.id]
}

resource "aws_efs_mount_target" "efs_mount_b" {
  file_system_id  = aws_efs_file_system.a4l_wordpress_content.id
  subnet_id       = aws_subnet.sn_app_b.id
  security_groups = [aws_security_group.sg_efs.id]
}

resource "aws_efs_mount_target" "efs_mount_c" {
  file_system_id  = aws_efs_file_system.a4l_wordpress_content.id
  subnet_id       = aws_subnet.sn_app_c.id
  security_groups = [aws_security_group.sg_efs.id]
}
