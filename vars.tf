variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}


// This variable contains the configuration settings for the EC2 and RDS instances
variable "settings" {
  description = "Configuration settings"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage   = 10
      engine              = "mysql"
      engine_version      = "8.0.32"
      instance_class      = "db.t4g.micro" // RDS instance type
      db_name             = "wordpress"
      skip_final_snapshot = true
    },
    "web_app" = {
      count         = 1           // the number of EC2 instances
      instance_type = "t4g.small" // the EC2 instance type
    }
  }
}

variable "email" {
  description = "email"
  type        = string
}

variable "wordpress_external_port" {
  description = "port to access from internet"
  type        = number
  default     = 80
}

# variable "external_phpmyadmin_port" {
#   description = "port to access from internet"
#   type        = number
#   default     = 8080
# }

variable "domain" {
  description = "wordpress domain"
  type        = string
}

variable "subdomain" {
  description = "wordpress subdomain"
  type        = string
}

variable "db_username" {
  description = "admin username"
  type        = string
  sensitive   = true
}


variable "db_password" {
  description = "admin password"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "porkbun api key"
  type        = string
  sensitive   = true
}

variable "secret_api_key" {
  description = "porkbun secret api key"
  type        = string
  sensitive   = true
}

