data "archive_file" "autoscaler-lambda" {
  output_path = "lambda/dist/autoscaler-payload.zip"
  source_file = "lambda/autoscaler.py"
  type        = "zip"
}

data "aws_iam_policy_document" "autoscaler-lambda-policy-document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "dns-query-log-group-policy-document" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.query-log-group.arn}/*"
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
