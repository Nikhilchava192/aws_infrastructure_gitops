variable "vpc_cidr" {
  type        = string
  description = "Base CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "AZs for subnets"
}