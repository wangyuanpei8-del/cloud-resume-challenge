# コンソールで作成済みのリソースを Terraform の管理下に取り込む
import {
  to = aws_dynamodb_table.visitor_count
  id = "visitor-count"
}
import {
  to = aws_lambda_function.visitor_counter
  id = "visitor-counter"
}
import {
  to = aws_iam_role.lambda_role
  id = "PowerUserRole"
}
import {
  to = aws_iam_role_policy.dynamodb_access
  id = "PowerUserRole:visitor-count-access"
}
import {
  to = aws_apigatewayv2_api.visitor_api
  id = "k8nzp59qa1"
}
import {
  to = aws_apigatewayv2_integration.lambda
  id = "k8nzp59qa1/w482t1s"
}
import {
  to = aws_apigatewayv2_route.get_count
  id = "k8nzp59qa1/pjgtfd2"
}
import {
  to = aws_apigatewayv2_stage.default
  id = "k8nzp59qa1/$default"
}
import {
  to = aws_lambda_permission.apigw
  id = "visitor-counter/1ed2e9a2-152b-5cac-afad-1ccced082b84"
}
