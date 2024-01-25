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

variable "server_debug" {
  default     = false
  description = "Setting to `true` enables debug mode, which enables cloudwatch logs for the server containers."
  type        = bool
}

variable "server_cpu_units" {
  default     = 1024
  description = "The number of cpu units used by the task running the Minecraft server."
  type        = number
}

variable "server_memory" {
  default     = 2048
  description = "The amount (in MiB) of memory used by the task running the Minecraft server."
  type        = number
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
