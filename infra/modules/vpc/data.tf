data "aws_vpc" "provisioned-vpc" {
  count = local.provisioned_vpc_enabled ? 1 : 0
  id    = var.vpc_id
}
