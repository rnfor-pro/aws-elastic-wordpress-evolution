resource "aws_launch_template" "wordpress_lt" {
  name                   = "Wordpress"
  image_id               = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type          = var.instance_type
  update_default_version = true

  vpc_security_group_ids = [aws_security_group.sg_wordpress.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh.tftpl", {}))

  iam_instance_profile {
    name = aws_iam_instance_profile.wordpress_instance_profile.name
  }

  lifecycle {
    create_before_destroy = true
  }
}
