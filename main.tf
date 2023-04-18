module "networks" {
  source = "./networks"

  availability_zones = data.aws_availability_zones.available.names

}

// Create a DB instance called "wordpress_db"
resource "aws_db_instance" "wordpress_db" {

  identifier        = "wordpress-db"
  allocated_storage = var.settings.database.allocated_storage
  engine            = var.settings.database.engine // "mysql"
  engine_version    = var.settings.database.engine_version
  instance_class    = var.settings.database.instance_class // "db.t4g.micro"

  db_name  = var.settings.database.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name = module.networks.wordpress_db_subnet_group.id
  publicly_accessible  = false

  vpc_security_group_ids = [module.networks.wordpress_db_sg.id]

  skip_final_snapshot = var.settings.database.skip_final_snapshot
}

resource "aws_key_pair" "wordpress_kp" {
  key_name = "wordpress_kp"

  public_key = tls_private_key.generated_key.public_key_openssh
}

// Create an EC2 instance named "wordpress_web"
resource "aws_instance" "wordpress_web" {
  count         = var.settings.web_app.count
  ami           = data.aws_ami.amazon_linux_arm64.id
  instance_type = var.settings.web_app.instance_type //  "t4g.small"
  subnet_id     = module.networks.wordpress_public_subnet[count.index].id
  key_name      = aws_key_pair.wordpress_kp.key_name

  // The security groups of the EC2 instance to connect to RDS.
  vpc_security_group_ids = [module.networks.wordpress_web_sg.id]

  user_data = data.template_file.userdata.rendered

  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

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