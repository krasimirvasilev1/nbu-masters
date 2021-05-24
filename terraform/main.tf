terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "aws_caller_identity" "this" {}
data "aws_region" "current" {}
data "aws_ecr_authorization_token" "token" {}

locals {
  ecr_address = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
  ecr_image   = format("%v/%v:%v", local.ecr_address, aws_ecr_repository.this.id, "1.0")
}

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "elsys-diplom-images"
  force_destroy = true
  acl           = "private"
}

module "lambda_function_from_container_image" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "elsys-lambda-alpr"
  description   = "Managed by Terraform"

  create_package = false

  ##################
  # Container Image
  ##################
  image_uri    = docker_registry_image.app.name
  package_type = "Image"
}

#################
# ECR Repository
#################
resource "aws_ecr_repository" "this" {
  name = "elsys-ecr"
}

###############################################
# Create Docker Image and push to ECR registry
###############################################

resource "docker_registry_image" "app" {
  name = local.ecr_image

  build {
    context        = "context"
    remote_context = "https://github.com/openalpr/openalpr.git"
  }
}
