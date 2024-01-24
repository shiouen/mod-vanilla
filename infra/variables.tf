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

variable "subdomain" {
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
