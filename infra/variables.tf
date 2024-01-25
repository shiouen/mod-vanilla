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
