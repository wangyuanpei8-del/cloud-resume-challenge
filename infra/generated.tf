# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "visitor-counter/1ed2e9a2-152b-5cac-afad-1ccced082b84"
resource "aws_lambda_permission" "apigw" {
  action                   = "lambda:InvokeFunction"
  event_source_token       = null
  function_name            = "visitor-counter"
  function_url_auth_type   = null
  invoked_via_function_url = null
  principal                = "apigateway.amazonaws.com"
  principal_org_id         = null
  qualifier                = null
  region                   = "ap-southeast-2"
  source_account           = null
  source_arn               = "arn:aws:execute-api:ap-southeast-2:331384580338:k8nzp59qa1/*/*/count"
  statement_id             = "1ed2e9a2-152b-5cac-afad-1ccced082b84"
}

# __generated__ by Terraform from "k8nzp59qa1"
resource "aws_apigatewayv2_api" "visitor_api" {
  api_key_selection_expression = "$request.header.x-api-key"
  body                         = null
  credentials_arn              = null
  description                  = null
  disable_execute_api_endpoint = false
  fail_on_warnings             = null
  ip_address_type              = "ipv4"
  name                         = "visitor-api"
  protocol_type                = "HTTP"
  region                       = "ap-southeast-2"
  route_key                    = null
  route_selection_expression   = "$request.method $request.path"
  tags                         = {}
  tags_all                     = {}
  target                       = null
  version                      = null
  cors_configuration {
    allow_credentials = false
    allow_headers     = []
    allow_methods     = ["GET"]
    allow_origins     = ["https://d23dnziyuzdous.cloudfront.net"]
    expose_headers    = []
    max_age           = 0
  }
}

# __generated__ by Terraform from "k8nzp59qa1/w482t1s"
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                        = "k8nzp59qa1"
  connection_id                 = null
  connection_type               = "INTERNET"
  content_handling_strategy     = null
  credentials_arn               = null
  description                   = null
  integration_method            = "POST"
  integration_subtype           = null
  integration_type              = "AWS_PROXY"
  integration_uri               = "arn:aws:lambda:ap-southeast-2:331384580338:function:visitor-counter"
  passthrough_behavior          = null
  payload_format_version        = "2.0"
  region                        = "ap-southeast-2"
  request_parameters            = {}
  request_templates             = {}
  template_selection_expression = null
  timeout_milliseconds          = 30000
}

# __generated__ by Terraform from "k8nzp59qa1/pjgtfd2"
resource "aws_apigatewayv2_route" "get_count" {
  api_id                              = "k8nzp59qa1"
  api_key_required                    = false
  authorization_scopes                = []
  authorization_type                  = "NONE"
  authorizer_id                       = null
  model_selection_expression          = null
  operation_name                      = null
  region                              = "ap-southeast-2"
  request_models                      = {}
  route_key                           = "GET /count"
  route_response_selection_expression = null
  target                              = "integrations/w482t1s"
}

# __generated__ by Terraform
resource "aws_lambda_function" "visitor_counter" {
  architectures                        = ["x86_64"]
  code_sha256                          = "m+bTKCBTWL51aWxHCxuNTlBjAhAvsPnPlzHQ9l1s4Pg="
  code_signing_config_arn              = null
  description                          = null
  filename                             = null
  function_name                        = "visitor-counter"
  handler                              = "lambda_function.lambda_handler"
  image_uri                            = null
  kms_key_arn                          = null
  layers                               = []
  memory_size                          = 128
  package_type                         = "Zip"
  publish                              = null
  publish_to                           = null
  region                               = "ap-southeast-2"
  replace_security_groups_on_destroy   = null
  replacement_security_group_ids       = null
  reserved_concurrent_executions       = -1
  role                                 = "arn:aws:iam::331384580338:role/PowerUserRole"
  runtime                              = "python3.14"
  s3_bucket                            = null
  s3_key                               = null
  s3_object_version                    = null
  skip_destroy                         = false
  source_kms_key_arn                   = null
  tags                                 = {}
  tags_all                             = {}
  timeout                              = 3
  use_resource_timeout_for_propagation = null
  ephemeral_storage {
    size = 512
  }
  logging_config {
    application_log_level = null
    log_format            = "Text"
    log_group             = "/aws/lambda/visitor-counter"
    system_log_level      = null
  }
  tracing_config {
    mode = "PassThrough"
  }
}

# __generated__ by Terraform from "k8nzp59qa1/$default"
resource "aws_apigatewayv2_stage" "default" {
  api_id                = "k8nzp59qa1"
  auto_deploy           = true
  client_certificate_id = null
  deployment_id         = "ctta5x"
  description           = null
  name                  = "$default"
  region                = "ap-southeast-2"
  stage_variables       = {}
  tags                  = {}
  tags_all              = {}
  default_route_settings {
    data_trace_enabled       = false
    detailed_metrics_enabled = false
    throttling_burst_limit   = 0
    throttling_rate_limit    = 0
  }
}

# __generated__ by Terraform from "PowerUserRole:visitor-count-access"
resource "aws_iam_role_policy" "dynamodb_access" {
  name = "visitor-count-access"
  policy = jsonencode({
    Statement = [{
      Action   = ["dynamodb:UpdateItem", "dynamodb:GetItem"]
      Effect   = "Allow"
      Resource = "arn:aws:dynamodb:ap-southeast-2:331384580338:table/visitor-count"
    }]
    Version = "2012-10-17"
  })
  role = "PowerUserRole"
}

# __generated__ by Terraform
resource "aws_dynamodb_table" "visitor_count" {
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "id"
  name                        = "visitor-count"
  range_key                   = null
  read_capacity               = 0
  region                      = "ap-southeast-2"
  restore_backup_arn          = null
  restore_date_time           = null
  restore_source_name         = null
  restore_source_table_arn    = null
  restore_to_latest_time      = null
  stream_enabled              = false
  table_class                 = "STANDARD"
  tags                        = {}
  tags_all                    = {}
  write_capacity              = 0
  attribute {
    name = "id"
    type = "S"
  }
  point_in_time_recovery {
    enabled                 = false
  }
  ttl {
    attribute_name = null
    enabled        = false
  }
}

# __generated__ by Terraform from "PowerUserRole"
resource "aws_iam_role" "lambda_role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  description           = "Power user role for lambda.amazonaws.com"
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "PowerUserRole"
  path                  = "/"
  permissions_boundary  = null
  tags                  = {}
  tags_all              = {}
}
