variable "aws_region" {
  default     = "us-east-1"
  description = "The default AWS region."
  nullable    = false
  type        = string
}

variable "domain_name" {
  description = "The domain name."
  type        = string
}

variable "minecraft_edition" {
  default = "java"
  type    = string

  validation {
    condition     = contains(["java", "bedrock"], var.minecraft_edition)
    error_message = "Valid values for `minecraft_edition`: `java`, `bedrock`"
  }
}

variable "minecraft_image_bedrock" {
  default = "itzg/minecraft-bedrock-server"
  type    = string
}

variable "minecraft_image_java" {
  default = "itzg/minecraft-server"
  type    = string
}

variable "subdomain_part" {
  default     = "minecraft"
  description = "The subdomain part."
  type        = string
}

variable "tags" {
  default     = {}
  description = "The resource tags."
  nullable    = false
  type        = map(string)
}

variable "vpc_id" {
  default     = null
  description = "The VPC id."
  type        = string
}
