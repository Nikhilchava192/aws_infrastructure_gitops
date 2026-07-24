terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Migration to Remote Backend
  # IMPORTANT: Update these string values with your manually created S3 Bucket and DynamoDB table names
  backend "s3" {
    bucket         = "YOUR-UNIQUE-TERRAFORM-STATE-BUCKET"
    key            = "gitops-iac/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "YOUR-TERRAFORM-LOCK-TABLE"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "compute" {
  source          = "./modules/compute"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids
  alb_sg_id       = module.security_groups.alb_sg_id
  app_sg_id       = module.security_groups.app_sg_id
}