# アクセス数を 1 増やして返す関数
# コードは GitHub Actions（.github/workflows/backend.yml）がデプロイするので、
# Terraform は設定（ランタイム・ロール・メモリなど）だけを管理する
resource "aws_lambda_function" "visitor_counter" {
  function_name = "visitor-counter"
  role          = aws_iam_role.visitor_counter.arn
  runtime       = "python3.14"
  handler       = "lambda_function.lambda_handler"
  memory_size   = 128
  timeout       = 3

  filename = "lambda.zip" # 初回作成時だけ必要。以降の変更は無視する

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# API Gateway からこの関数を呼び出す許可（GET /count のみ）
resource "aws_lambda_permission" "apigw" {
  statement_id  = "1ed2e9a2-152b-5cac-afad-1ccced082b84" # コンソールが自動で付けた ID をそのまま使用
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*/count"
}
