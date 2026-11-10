# HTTP API：ブラウザからの GET /count を Lambda に渡す
resource "aws_apigatewayv2_api" "visitor_api" {
  name          = "visitor-api"
  protocol_type = "HTTP"

  # ブラウザからの呼び出しは、このサイトのオリジンだけ許可
  cors_configuration {
    allow_methods = ["GET"]
    allow_origins = ["https://d23dnziyuzdous.cloudfront.net"]
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.visitor_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.visitor_counter.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_count" {
  api_id    = aws_apigatewayv2_api.visitor_api.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.visitor_api.id
  name        = "$default"
  auto_deploy = true
}
