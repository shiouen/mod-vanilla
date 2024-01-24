locals {
  project_id = "${var.subdomain}.${var.domain_name}"

  tags = merge(var.tags, {
    "project-id" = local.project_id
  })
}
