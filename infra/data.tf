data "archive_file" "autoscaler-lambda" {
  output_path = "lambda/dist/autoscaler-payload.zip"
  source_file = "lambda/autoscaler.py"
  type        = "zip"
}

//noinspection X,MissingProperty
data "aws_iam_policy" "autoscaler-lambda-basic-execution-policy" {
  name     = "AWSLambdaBasicExecutionRole"
  provider = aws.us-east-1
}

data "aws_iam_policy_document" "autoscaler-lambda-policy-document" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "file-system-policy-document" {
  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeFileSystems",
    ]

    resources = [aws_efs_file_system.file-system.arn]

    condition {
      test     = "StringEquals"
      values   = [aws_efs_access_point.file-system-access-point.arn]
      variable = "elasticfilesystem:AccessPointArn"
    }
  }
}

data "aws_iam_policy_document" "query-log-group-policy-document" {
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

data "aws_iam_policy_document" "task-definition-assume-role-policy-document" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_route53_zone" "root-hosted-zone" {
  name = var.domain_name
}
