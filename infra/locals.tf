locals {
  ecs_volume_name = "data"

  efs_gid = 1000
  efs_uid = 1000

  minecraft_server_config = local.minecraft_server_configs_by_edition[var.minecraft_edition]
  minecraft_server_configs_by_edition = {
    "java" = {
      image    = var.minecraft_image_java
      port     = 25565
      protocol = "TCP"
    }
    "bedrock" = {
      image    = var.minecraft_image_bedrock
      port     = 19132
      protocol = "UDP"
    }
  }

  subdomain = "${var.subdomain_part}.${var.domain_name}"

  tags = merge(var.tags, {
    "project-id" = local.subdomain
  })
}
