data "aws_iam_policy_document" "dns_query_log_group_policy_document" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.dns_query_log_group.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["route53.amazonaws.com"]
    }
  }
}

data "aws_route53_zone" "root-hosted-zone" {
  name = var.domain_name
}
