resource "aws_cloudwatch_log_group" "query-log-group" {
  name_prefix       = "mod-${local.subdomain}-dns-queries-"
  retention_in_days = 3
  provider          = aws.us-east-1
}

resource "aws_cloudwatch_log_resource_policy" "query-log-resource-policy" {
  policy_document = data.aws_iam_policy_document.dns-query-log-group-policy-document.json
  policy_name     = random_id.query-log-resource-policy-name.dec
#  provider        = aws.us-east-1
}

resource "aws_route53_zone" "hosted-zone" {
  name = local.subdomain
}

resource "aws_route53_query_log" "query-log" {
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.query-log-group.arn
  zone_id                  = aws_route53_zone.hosted-zone.zone_id
}

resource "random_id" "query-log-resource-policy-name" {
  byte_length = 10
  prefix      = "mod-${local.subdomain}-"
}
