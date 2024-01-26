locals {
  public_subnet_cidr_blocks_per_az = {
    "${var.aws_region}a" = "10.0.0.0/19"
    "${var.aws_region}b" = "10.0.32.0/19"
    "${var.aws_region}c" = "10.0.64.0/19"
  }
  isolated_subnet_cidr_blocks_per_az = {
    "${var.aws_region}a" = "10.0.96.0/19"
    "${var.aws_region}b" = "10.0.128.0/19"
    "${var.aws_region}c" = "10.0.160.0/19"
  }

  provisioned_vpc_enabled = var.vpc_id != null

  vpc_id            = local.provisioned_vpc_enabled ? data.aws_vpc.provisioned-vpc[0].id : aws_vpc.vpc[0].id
  public_subnet_ids = local.provisioned_vpc_enabled ? data.aws_subnets.provisioned-subnets[0].ids : [
    aws_subnet.public[0].id, aws_subnet.public[1].id, aws_subnet.public[2].id
  ]
}
