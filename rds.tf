resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [aws_subnet.sn_db_a.id, aws_subnet.sn_db_b.id, aws_subnet.sn_db_c.id]

  tags = {
    Name = "WordPressRDSSubNetGroup"
  }
}

resource "aws_db_instance" "wordpress_db" {
  identifier              = "a4lwordpress"
  engine                  = "mysql"
  engine_version          = "8.4.8"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_name                 = var.db_name
  username                = var.db_user
  password                = var.db_password
  publicly_accessible     = false
  availability_zone       = data.aws_availability_zones.available.names[0]
  db_subnet_group_name    = aws_db_subnet_group.wordpress_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.sg_database.id]
  parameter_group_name    = "default.mysql8.4"
  skip_final_snapshot     = true
  backup_retention_period = 0

  tags = {
    Name = "WordpressDB"
  }
}
