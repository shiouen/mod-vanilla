module "vpc" {
  source = "./modules/vpc"
  vpc_id = var.vpc_id
}
