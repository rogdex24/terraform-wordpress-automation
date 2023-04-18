
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

  availability_zone = var.availability_zones[count.index]


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

  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "wordpress_private_subnet_${count.index}"
  }
}

resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name        = "wordpress_db_subnet_group"
  description = "DB subnet group for wordpress"

  subnet_ids = [for subnet in aws_subnet.wordpress_private_subnet : subnet.id]
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

resource "aws_route_table" "wordpress_private_rt" {
  vpc_id = aws_vpc.wordpress_vpc.id

  // Since this is going to be a private route table, 
  // we will not be adding a route
}

// Here we are going to add the private subnets to the route table "wordpress_private_rt
resource "aws_route_table_association" "private" {

  count = var.subnet_count.private

  route_table_id = aws_route_table.wordpress_private_rt.id

  subnet_id = aws_subnet.wordpress_private_subnet[count.index].id
}


