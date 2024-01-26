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

data "aws_iam_policy_document" "cluster-policy-document" {
  statement {
    actions   = ["ecs:*"]
    effect    = "Allow"
    resources = ["${aws_ecs_task_definition.task-definition.arn}/*"]
  }

  statement {
    actions   = ["ec2:DescribeNetworkInterfaces"]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "file-system-policy-document" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeFileSystems",
    ]
    effect    = "Allow"
    resources = [aws_efs_file_system.file-system.arn]

    condition {
      test     = "StringEquals"
      values   = [aws_efs_access_point.file-system-access-point.arn]
      variable = "elasticfilesystem:AccessPointArn"
    }
  }
}

data "aws_iam_policy_document" "hosted-zone-policy-document" {
  statement {
    actions = [
      "route53:GetHostedZone",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    effect    = "Allow"
    //noinspection HILUnresolvedReference
    resources = [aws_route53_zone.hosted-zone.arn]
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

data "aws_iam_policy_document" "server-notifications-topic-policy-document" {
  statement {
    actions = ["sns:Publish"]
    effect  = "Allow"

    resources = [aws_sns_topic.server-notifications-topic.arn]

    principals {
      identifiers = [aws_iam_role.task-definition-role.arn]
      type        = "AWS"
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
