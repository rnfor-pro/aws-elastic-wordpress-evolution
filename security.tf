resource "aws_security_group" "sg_load_balancer" {
  name   = "SG-LoadBalancer"
  vpc_id = aws_vpc.a4l_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "SG-LoadBalancer" }
}

resource "aws_security_group" "sg_wordpress" {
  name   = "SG-Wordpress"
  vpc_id = aws_vpc.a4l_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_load_balancer.id]
    description     = "Allow HTTP only from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "SG-Wordpress" }
}

resource "aws_security_group" "sg_database" {
  name   = "A4LVPC-SGDatabase"
  vpc_id = aws_vpc.a4l_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_wordpress.id]
    description     = "Allow MySQL from WordPress instances"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "A4LVPC-SGDatabase" }
}

resource "aws_security_group" "sg_efs" {
  name   = "A4LVPC-SGEFS"
  vpc_id = aws_vpc.a4l_vpc.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_wordpress.id]
    description     = "Allow NFS/EFS from WordPress instances"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "A4LVPC-SGEFS" }
}
