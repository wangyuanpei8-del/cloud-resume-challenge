# Lambda のコードは GitHub Actions がデプロイするので、Terraform は設定だけを管理する
resource "aws_lambda_function" "visitor_counter" {
  filename = "lambda.zip"
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}
