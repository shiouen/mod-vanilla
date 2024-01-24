resource "aws_cloudwatch_log_group" "dns_query_log_group" {
  name_prefix = "mod-${local.subdomain}-dns-queries-"
  retention_in_days = 3
  provider = aws.us-east-1
}

resource "aws_cloudwatch_log_resource_policy" "dns_query_log_group_policy" {
  policy_document = data.aws_iam_policy_document.dns_query_log_group_policy_document.json
  policy_name = "hmm"
}
