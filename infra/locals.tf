locals {
  ecs_volume_name = "data"

  efs_gid = 1000
  efs_uid = 1000

  subdomain = "${var.subdomain_part}.${var.domain_name}"

  tags = merge(var.tags, {
    "project-id" = local.subdomain
  })
}
