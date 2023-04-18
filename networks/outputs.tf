output "wordpress_web_sg" {
  value = aws_security_group.wordpress_web_sg
}
output "wordpress_db_sg" {
  value = aws_security_group.wordpress_db_sg
}
output "wordpress_public_subnet" {
  value = aws_subnet.wordpress_public_subnet
}

output "wordpress_db_subnet_group" {
  value = aws_db_subnet_group.wordpress_db_subnet_group
}


