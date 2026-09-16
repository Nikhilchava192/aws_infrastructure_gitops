variable "aws_region" {
  default = "us-east-1"
}

variable "environment" {
  default = "prod"
}

variable "key_name" {
  description = "Name of existing AWS EC2 Key Pair"
  type        = "string"
}