terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

module "ansible_controller" {
  source = "./modules/ansible-controller"

  instance_name = var.instance_name
  ami_id           = var.ami_id
  instance_type    = var.instance_type_controller

}

module "k8s_master" {
  source = "./modules/k8s_master"

  ami_id           = var.ami_id
  instance_type    = var.instance_type_master
  vpc_id           = module.ansible_controller.vpc_id
  subnet_id        = module.ansible_controller.subnet_id
  controller_sg_id = module.ansible_controller.sg_id
}

module "k8s_workers" {
  source = "./modules/k8s_workers"

  ami_id           = var.ami_id
  instance_type    = var.instance_type_worker
  vpc_id           = module.ansible_controller.vpc_id
  subnet_id        = module.ansible_controller.subnet_id
  controller_sg_id = module.ansible_controller.sg_id
}


