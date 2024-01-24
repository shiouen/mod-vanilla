resource "aws_cloudwatch_log_group" "dns_query_log_group" {
  name_prefix = "mod-${local.subdomain}-dns-queries"
  retention_in_days = 3
  provider = aws.us-east-1
}
