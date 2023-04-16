data "aws_availability_zones" "available" {
  state = "available"
}

resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "ssh_private_key" {
  content         = tls_private_key.generated_key.private_key_pem
  file_permission = "400"
  filename        = "./.ssh/private_ssh_key.pem"

}

resource "local_sensitive_file" "ssh_public_key" {
  content  = tls_private_key.generated_key.public_key_openssh
  filename = "./.ssh/public_ssh_key.pub"

}

resource "aws_vpc" "wordpress_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "wordpress_vpc"
  }
}

resource "aws_internet_gateway" "wordpress_igw" {

  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name = "wordpress_igw"
  }
}

resource "aws_subnet" "wordpress_public_subnet" {
  // set to 1
  count = var.subnet_count.public

  vpc_id = aws_vpc.wordpress_vpc.id

  cidr_block = var.public_subnet_cidr_blocks[count.index]

  availability_zone = data.aws_availability_zones.available.names[count.index]


  tags = {
    Name = "wordpress_public_subnet_${count.index}"
  }
}

// Create a group of private subnets based on the variable subnet_count.private
resource "aws_subnet" "wordpress_private_subnet" {
  // set to 2
  count = var.subnet_count.private

  vpc_id = aws_vpc.wordpress_vpc.id

  cidr_block = var.private_subnet_cidr_blocks[count.index]

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "wordpress_private_subnet_${count.index}"
  }
}

resource "aws_route_table" "wordpress_public_rt" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }
}


resource "aws_route_table_association" "public" {
  count = var.subnet_count.public

  route_table_id = aws_route_table.wordpress_public_rt.id

  subnet_id = aws_subnet.wordpress_public_subnet[count.index].id
}

// Create a private route table named "wordpress_private_rt"
resource "aws_route_table" "wordpress_private_rt" {
  vpc_id = aws_vpc.wordpress_vpc.id

  // Since this is going to be a private route table, 
  // we will not be adding a route
}

// Here we are going to add the private subnets to the
// route table "wordpress_private_rt"
resource "aws_route_table_association" "private" {

  count = var.subnet_count.private

  route_table_id = aws_route_table.wordpress_private_rt.id

  subnet_id = aws_subnet.wordpress_private_subnet[count.index].id
}

// Create a security for the EC2 instances called "wordpress_web_sg"
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

  ingress {
    description = "Allow SSH from my computer"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    // This is using the variable "my_ip" for SSH
    cidr_blocks = ["${var.my_ip}/32"]
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

resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name        = "wordpress_db_subnet_group"
  description = "DB subnet group for wordpress"

  subnet_ids = [for subnet in aws_subnet.wordpress_private_subnet : subnet.id]
}

// Create a DB instance called "wordpress_database"
resource "aws_db_instance" "wordpress_database" {
  // set to 10

  allocated_storage = var.settings.database.allocated_storage

  //  set to "mysql"
  engine = var.settings.database.engine

  // set to "8.0.27"
  engine_version = var.settings.database.engine_version

  // set to "db.t4g.micro"
  instance_class = var.settings.database.instance_class

  // set to "wordpress"
  db_name = var.settings.database.db_name

  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.wordpress_db_subnet_group.id
  publicly_accessible  = false

  vpc_security_group_ids = [aws_security_group.wordpress_db_sg.id]

  skip_final_snapshot = var.settings.database.skip_final_snapshot
}

resource "aws_key_pair" "wordpress_kp" {
  key_name = "wordpress_kp"

  #   public_key = file("wordpress_kp.pub")
  public_key = tls_private_key.generated_key.public_key_openssh
}

// Create an EC2 instance named "wordpress_web"
resource "aws_instance" "wordpress_web" {
  count = var.settings.web_app.count
  ami   = var.settings.web_app.ami_id
  // set to "t4g.small"
  instance_type = var.settings.web_app.instance_type
  subnet_id     = aws_subnet.wordpress_public_subnet[count.index].id
  key_name      = aws_key_pair.wordpress_kp.key_name

  // The security groups of the EC2 instance to connect to RDS.
  vpc_security_group_ids = [aws_security_group.wordpress_web_sg.id]

  tags = {
    Name = "wordpressl_web_${count.index}"
  }
}

// Elastic IP for the EC2 instance
resource "aws_eip" "wordpress_web_eip" {
  count = var.settings.web_app.count

  instance = aws_instance.wordpress_web[count.index].id

  vpc = true

  tags = {
    Name = "wordpress_web_eip_${count.index}"
  }
}

