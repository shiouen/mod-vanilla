resource "aws_cloudwatch_log_group" "query-log-group" {
  name_prefix       = "mod-${local.subdomain}-dns-queries-"
  retention_in_days = 3
  provider          = aws.us-east-1
}

resource "aws_cloudwatch_log_resource_policy" "query-log-resource-policy" {
  policy_document = data.aws_iam_policy_document.dns-query-log-group-policy-document.json
  policy_name     = random_id.query-log-resource-policy-name.dec
  provider        = aws.us-east-1
}

resource "aws_route53_query_log" "query-log" {
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.query-log-group.arn
  provider                 = aws.us-east-1
  zone_id                  = aws_route53_zone.hosted-zone.zone_id
}

// the record is a dummy, to be changed whenever the container launches
// allow_overwrite is recommended here because of the resource-drift
resource "aws_route53_record" "hosted-zone-a-record" {
  allow_overwrite = true
  name            = local.subdomain
  provider        = aws.us-east-1
  records         = ["192.168.1.1"]
  ttl             = 30
  type            = "A"
  zone_id         = data.aws_route53_zone.root-hosted-zone.zone_id
}

resource "aws_route53_record" "root-hosted-zone-ns-record" {
  name     = local.subdomain
  provider = aws.us-east-1
  records  = aws_route53_zone.hosted-zone.name_servers
  ttl      = 172800
  type     = "NS"
  zone_id = data.aws_route53_zone.root-hosted-zone.zone_id
}

resource "aws_route53_zone" "hosted-zone" {
  name     = local.subdomain
  provider = aws.us-east-1
}

resource "random_id" "query-log-resource-policy-name" {
  byte_length = 10
  prefix      = "mod-${local.subdomain}-"
}
