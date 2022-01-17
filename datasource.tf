data "aws_iam_account_alias" "current" {}



# Lamda function
data "archive_file" "aws_to_soc" {
  type        = "zip"
  source_file = "${path.module}/functions/lambda_function.py"
  output_path = "${path.module}/functions/lambda_function.zip"
}