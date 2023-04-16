variable "aws_region" {
  default = "ap-south-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public  = 1,
    private = 2
  }
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
      instance_class      = "db.t4g.micro" // rds instance type
      db_name             = "wordpress"    // database name
      skip_final_snapshot = true
    },
    "web_app" = {
      count         = 1          // the number of EC2 instances
      instance_type = "t4g.small" // the EC2 instance
      ami_id = "ami-04daff085607f4847"
    }
  }
}


variable "public_subnet_cidr_blocks" {
  description = "Available CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}


variable "private_subnet_cidr_blocks" {
  description = "Available CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
  ]
}


variable "my_ip" {
  description = "Your IP address"
  type        = string
  sensitive   = true
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

