resource "aws_vpc" "vpc" {
  count = local.provisioned_vpc_enabled ? 0 : 1
  cidr_block = "10.0.0.0/16"
}
