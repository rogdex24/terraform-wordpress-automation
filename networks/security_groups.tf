// Create a security for the EC2 instance
resource "aws_security_group" "wordpress_web_sg" {
  name        = "wordpress_web_sg"
  description = "Security group for wordpress web servers"
  vpc_id      = aws_vpc.wordpress_vpc.id

  // Wordpress accessible through port 80
  ingress {
    description = "Allow all traffic through HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // allow all traffic through HTTPS
  ingress {
    description = "Allow all traffic through HTTPS"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    
  # // allow all traffic for port 8080 - phpmyadmin
  # ingress {
  #   description = "Allow all traffic through HTTPS"
  #   from_port   = var.external_phpmyadmin_port
  #   to_port     = var.external_phpmyadmin_port
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    description = "Allow All SSHr"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # // This is using the variable "my_ip" for SSH from your IP
    # cidr_blocks = ["${var.my_ip}/32"]
  }


  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpressl_web_sg"
  }
}

// Create a security group for the RDS instances called "wordpress_db_sg"
resource "aws_security_group" "wordpress_db_sg" {
  name        = "wordpress_db_sg"
  description = "Security group for wordpress databases"

  vpc_id = aws_vpc.wordpress_vpc.id

  // "Only the EC2 instances should be able to communicate with RDS." - Not Publicly accessible
  ingress {
    description     = "Allow MySQL traffic from only the web sg"
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_web_sg.id]
  }

  tags = {
    Name = "wordpress_db_sg"
  }
}