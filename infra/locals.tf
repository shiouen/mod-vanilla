locals {
  subdomain = "${var.subdomain_part}.${var.domain_name}"

  tags = merge(var.tags, {
    "project-id" = local.subdomain
  })
}
