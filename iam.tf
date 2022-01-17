# Iam permissions for lambda
resource "aws_iam_role" "role_for_lambda" {
  name               = join("-",["securityhub-findings", local.name])
  assume_role_policy =  <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
tags = local.tags
}


resource "aws_iam_policy" "aws_to_soc_lambda" {
  name        = join("-", ["securityhub-lambda",local.name])
  path        = "/"
  description = "policy for lambda with basic execrole and listing organization permission"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "permission0",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "${split("log-group", "${aws_cloudwatch_log_group.aws_to_soc.arn}")[0]}*"
        },
        {
            "Sid": "permission1",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "${aws_cloudwatch_log_group.aws_to_soc.arn}"
        },
        {
            "Sid": "permission2",
            "Effect": "Allow",
            "Action": "organizations:ListParents",
            "Resource": "*"
        }
    ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "attach_policy" {
  name       = "policy-attachment-to-lambda-role"
  roles      = [aws_iam_role.role_for_lambda.name]
  policy_arn = aws_iam_policy.aws_to_soc_lambda.arn
}