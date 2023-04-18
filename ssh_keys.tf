resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "public_key" {
  content  = tls_private_key.generated_key.public_key_openssh
  filename = "./.ssh/wordpress_kp.pub"

}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.generated_key.private_key_pem
  file_permission = "400"
  filename        = "./.ssh/wordpress_kp.pem"

}
