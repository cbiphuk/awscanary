provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Owner = "Terraform"
      Repo = "git@github.com:cbiphuk/awscanary.git"
    }
  }
}

resource "aws_synthetics_canary" "canary_artifactory" {
  artifact_s3_location = format("s3://canary-data-%s/", var.name)
  execution_role_arn   = aws_iam_role.cloudwatch_canary_role.arn
  handler              = var.handler
  name                 = format("canary-%s", var.name)
  runtime_version      = var.runtime_version
  zip_file             = format("script/%s",var.script_name)

  schedule {
    expression = "rate(0 minute)"
  }
}

resource "aws_s3_bucket" "canary_data" {
  bucket = format("canary-data-%s",var.name)

  tags = {
    Name = "Canary-data"
  }
}

resource "aws_iam_role" "cloudwatch_canary_role" {
  name                 = format("canary-%s-role", var.name)

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "cloudwatch_canary_policy" {
  name                 = format("canary-%s-policy", var.name)

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "${aws_s3_bucket.canary_data.arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "xray:PutTraceSegments",
                "secretsmanager:GetRandomPassword",
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": "cloudwatch:PutMetricData",
            "Condition": {
                "StringEquals": {
                    "cloudwatch:namespace": "CloudWatchSynthetics"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cloudwatch_canary_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_canary_policy.arn
  role       = aws_iam_role.cloudwatch_canary_role.name
}
