locals {
  provisioned_vpc_enabled = var.vpc_id != null
  vpc_id = local.provisioned_vpc_enabled ? data.aws_vpc.provisioned-vpc[0].id : aws_vpc.vpc[0].id
}
