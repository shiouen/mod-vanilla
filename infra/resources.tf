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

resource "aws_cloudwatch_log_subscription_filter" "query-log-subscription-filter" {
  destination_arn = aws_lambda_function.autoscaler-lambda.arn
  filter_pattern  = local.subdomain
  log_group_name  = aws_cloudwatch_log_group.query-log-group.name
  name            = random_id.query-log-subscription-filter-name.dec
  provider        = aws.us-east-1
}

resource "aws_iam_role" "autoscaler-lambda-role" {
  assume_role_policy = data.aws_iam_policy_document.autoscaler-lambda-policy-document.json
  name_prefix        = "mod-${local.subdomain}-"
  provider           = aws.us-east-1
}

resource "aws_iam_role_policy_attachment" "autoscaler-lambda-basic-execution-policy-attachment" {
  policy_arn = data.aws_iam_policy.autoscaler-lambda-basic-execution-policy.arn
  provider   = aws.us-east-1
  role       = aws_iam_role.autoscaler-lambda-role.name
}

resource "aws_lambda_function" "autoscaler-lambda" {
  filename         = data.archive_file.autoscaler-lambda.output_path
  function_name    = random_id.autoscaler-lambda-name.dec
  handler          = "autoscaler.handler"
  provider         = aws.us-east-1
  role             = aws_iam_role.autoscaler-lambda-role.arn
  runtime          = "python3.8"
  source_code_hash = data.archive_file.autoscaler-lambda.output_base64sha256

  // TODO add REGION: config.serverRegion, CLUSTER: constants.CLUSTER_NAME, SERVICE: constants.SERVICE_NAME
  environment {
    variables = {
    }
  }
}

resource "aws_lambda_permission" "query-log-lambda-permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.autoscaler-lambda.function_name
  principal     = "logs.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.query-log-group.arn}:*"
  provider      = aws.us-east-1
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
  zone_id  = data.aws_route53_zone.root-hosted-zone.zone_id
}

resource "aws_route53_zone" "hosted-zone" {
  name     = local.subdomain
  provider = aws.us-east-1
}

resource "random_id" "query-log-resource-policy-name" {
  byte_length = 10
  prefix      = "mod-${local.subdomain}-"
}

resource "random_id" "autoscaler-lambda-name" {
  byte_length = 10
  prefix      = "mod-autoscaler-"
}

resource "random_id" "query-log-subscription-filter-name" {
  byte_length = 10
  prefix      = "mod-${local.subdomain}-"
}
