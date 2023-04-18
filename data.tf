data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux_arm64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "template_file" "dockercompose" {
  template = file("./template/docker-compose.tpl")

  vars = {
    dbhost     = aws_db_instance.wordpress_db.address
    dbuser     = aws_db_instance.wordpress_db.username
    dbpassword = aws_db_instance.wordpress_db.password
    dbname     = var.settings.database.db_name
    email      = var.email
    domain     = var.domain
    subdomain  = var.subdomain

  }
}

// Update DNS Records
data "template_file" "userdata" {
  template = file("./template/startup.tpl")

  vars = {
    dockercompose = data.template_file.dockercompose.rendered
    email         = var.email
    domain        = var.domain
  }

}

data "http" "update_dns_record_wordpress" {
  url    = "https://porkbun.com/api/json/v3/dns/editByNameType/${var.domain}/A/${var.subdomain}"
  method = "POST"

  request_body = jsonencode({
    secretapikey = var.secret_api_key
    apikey       = var.api_key
    content      = aws_eip.wordpress_web_eip[0].public_ip
    ttl          = "600"
  })

  depends_on = [aws_eip.wordpress_web_eip]
}

data "http" "update_dns_record_admin" {
  url    = "https://porkbun.com/api/json/v3/dns/editByNameType/${var.domain}/A/admin"
  method = "POST"

  request_body = jsonencode({
    secretapikey = var.secret_api_key
    apikey       = var.api_key
    content      = aws_eip.wordpress_web_eip[0].public_ip
    ttl          = "600"
  })

  depends_on = [aws_eip.wordpress_web_eip]
}

