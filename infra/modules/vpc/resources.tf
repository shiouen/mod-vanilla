resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc[0].id
}

resource "aws_vpc" "vpc" {
  count      = local.provisioned_vpc_enabled ? 0 : 1
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = random_id.vpc-name.dec
  }
}

resource "aws_subnet" "public" {
  count      = local.provisioned_vpc_enabled ? 0 : length(local.public_subnet_cidr_blocks_per_az)
  cidr_block = element(values(local.public_subnet_cidr_blocks_per_az), count.index)
  vpc_id     = aws_vpc.vpc[0].id

  map_public_ip_on_launch = true
  availability_zone       = element(keys(local.public_subnet_cidr_blocks_per_az), count.index)

  tags = {
    Name                                = random_id.public-subnet-name[count.index].dec
    "${var.vpc_public_subnet_tag_name}" = "${var.vpc_public_subnet_tag_value}"
  }
}

resource "aws_subnet" "isolated" {
  count      = local.provisioned_vpc_enabled ? 0 : length(local.isolated_subnet_cidr_blocks_per_az)
  cidr_block = element(values(local.isolated_subnet_cidr_blocks_per_az), count.index)
  vpc_id     = aws_vpc.vpc[0].id

  map_public_ip_on_launch = false
  availability_zone       = element(keys(local.isolated_subnet_cidr_blocks_per_az), count.index)

  tags = {
    Name                                  = random_id.isolated-subnet-name[count.index].dec
    "${var.vpc_isolated_subnet_tag_name}" = "${var.vpc_isolated_subnet_tag_value}"
  }
}

resource "random_id" "isolated-subnet-name" {
  byte_length = 10
  count       = 3
  prefix      = "mod-isolated-subnet-"
}

resource "random_id" "vpc-name" {
  byte_length = 10
  prefix      = "mod-vpc-"
}

resource "random_id" "public-subnet-name" {
  byte_length = 10
  count       = 3
  prefix      = "mod-public-subnet-"
}
