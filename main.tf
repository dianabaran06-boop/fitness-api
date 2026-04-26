
########################################
# IAM ASSUME ROLE
########################################

locals {
  assume = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

########################################
# TRAINERS ROLE
########################################

resource "aws_iam_role" "trainers_role" {
  name               = "trainers-role"
  assume_role_policy = local.assume
}

resource "aws_iam_role_policy" "trainers_policy" {
  name = "trainers-policy"
  role = aws_iam_role.trainers_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["logs:*"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = ["dynamodb:Scan"],
        Resource = data.aws_dynamodb_table.trainers.arn
      }
    ]
  })
}

########################################
# WORKOUTS ROLE
########################################

resource "aws_iam_role" "workouts_role" {
  name               = "workouts-role"
  assume_role_policy = local.assume
}

resource "aws_iam_role_policy" "workouts_policy" {
  name = "workouts-policy"
  role = aws_iam_role.workouts_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["logs:*"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = ["dynamodb:*"],
        Resource = data.aws_dynamodb_table.workouts.arn
      }
    ]
  })
}

########################################
# LAMBDA RUNTIME
########################################

locals {
  runtime = "nodejs18.x"
}

########################################
# LAMBDA FUNCTIONS
########################################

resource "aws_lambda_function" "get_trainers" {
  function_name = "get-trainers"
  role          = aws_iam_role.trainers_role.arn
  handler       = "index.handler"
  runtime       = local.runtime
  filename      = "${path.module}/lambda/get-all-trainers.zip"

  environment {
    variables = {
      TABLE_NAME = data.aws_dynamodb_table.trainers.name
    }
  }
}

resource "aws_lambda_function" "get_workouts" {
  function_name = "get-workouts"
  role          = aws_iam_role.workouts_role.arn
  handler       = "index.handler"
  runtime       = local.runtime
  filename      = "${path.module}/lambda/get-all-workouts.zip"

  environment {
    variables = {
      TABLE_NAME = data.aws_dynamodb_table.workouts.name
    }
  }
}

resource "aws_lambda_function" "get_workout" {
  function_name = "get-workout"
  role          = aws_iam_role.workouts_role.arn
  handler       = "index.handler"
  runtime       = local.runtime
  filename      = "${path.module}/lambda/get-workout.zip"

  environment {
    variables = {
      TABLE_NAME = data.aws_dynamodb_table.workouts.name
    }
  }
}

resource "aws_lambda_function" "save_workout" {
  function_name = "save-workout"
  role          = aws_iam_role.workouts_role.arn
  handler       = "index.handler"
  runtime       = local.runtime
  filename      = "${path.module}/lambda/save-workout.zip"

  environment {
    variables = {
      TABLE_NAME = data.aws_dynamodb_table.workouts.name
    }
  }
}

resource "aws_lambda_function" "update_workout" {
  function_name = "update-workout"
  role          = aws_iam_role.workouts_role.arn
  handler       = "index.handler"
  runtime       = local.runtime
  filename      = "${path.module}/lambda/update-workout.zip"

  environment {
    variables = {
      TABLE_NAME = data.aws_dynamodb_table.workouts.name
    }
  }
}

resource "aws_lambda_function" "delete_workout" {
  function_name = "delete-workout"
  role          = aws_iam_role.workouts_role.arn
  handler       = "index.handler"
  runtime       = local.runtime
  filename      = "${path.module}/lambda/delete-workout.zip"

  environment {
    variables = {
      TABLE_NAME = data.aws_dynamodb_table.workouts.name
    }
  }
}

########################################
# API GATEWAY
########################################

resource "aws_api_gateway_rest_api" "api" {
  name = "fitness-api"
}

########################################
# RESOURCES
########################################

resource "aws_api_gateway_resource" "workouts" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "workouts"
}

resource "aws_api_gateway_resource" "workout_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.workouts.id
  path_part   = "{id}"
}

resource "aws_api_gateway_resource" "trainers" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "trainers"
}

########################################
# GET /workouts
########################################

resource "aws_api_gateway_method" "get_workouts" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.workouts.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_workouts" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.workouts.id
  http_method             = aws_api_gateway_method.get_workouts.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_workouts.invoke_arn
}

resource "aws_lambda_permission" "get_workouts" {
  statement_id  = "AllowGetWorkouts"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_workouts.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

########################################
# POST /workouts
########################################

resource "aws_api_gateway_method" "post_workouts" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.workouts.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_workouts" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.workouts.id
  http_method             = aws_api_gateway_method.post_workouts.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.save_workout.invoke_arn
}

resource "aws_lambda_permission" "post_workouts" {
  statement_id  = "AllowPostWorkouts"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.save_workout.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

########################################
# GET /trainers
########################################

resource "aws_api_gateway_method" "get_trainers" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.trainers.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_trainers" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.trainers.id
  http_method             = aws_api_gateway_method.get_trainers.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_trainers.invoke_arn
}

resource "aws_lambda_permission" "get_trainers" {
  statement_id  = "AllowGetTrainers"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_trainers.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

########################################
# GET /workouts/{id}
########################################

resource "aws_api_gateway_method" "get_workout" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.workout_id.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_workout" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.workout_id.id
  http_method             = aws_api_gateway_method.get_workout.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_workout.invoke_arn
}

resource "aws_lambda_permission" "get_workout" {
  statement_id  = "AllowGetWorkout"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_workout.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

########################################
# PUT /workouts/{id}
########################################

resource "aws_api_gateway_method" "put_workout" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.workout_id.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "put_workout" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.workout_id.id
  http_method             = aws_api_gateway_method.put_workout.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_workout.invoke_arn
}

resource "aws_lambda_permission" "put_workout" {
  statement_id  = "AllowPutWorkout"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_workout.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

########################################
# DELETE /workouts/{id}
########################################

resource "aws_api_gateway_method" "delete_workout" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.workout_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_workout" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.workout_id.id
  http_method             = aws_api_gateway_method.delete_workout.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_workout.invoke_arn
}

resource "aws_lambda_permission" "delete_workout" {
  statement_id  = "AllowDeleteWorkout"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_workout.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

########################################
# DEPLOYMENT + STAGE
########################################

resource "aws_api_gateway_deployment" "deploy" {
  depends_on = [
    aws_api_gateway_integration.get_workouts,
    aws_api_gateway_integration.post_workouts,
    aws_api_gateway_integration.get_trainers,
    aws_api_gateway_integration.get_workout,
    aws_api_gateway_integration.put_workout,
    aws_api_gateway_integration.delete_workout
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deploy.id
}

########################################
# S3 FRONTEND
########################################

resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id

  depends_on = [aws_s3_bucket_public_access_block.frontend]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = ["s3:GetObject"],
      Resource = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
}

########################################
# OUTPUT
########################################

output "frontend_url" {
  value = aws_s3_bucket_website_configuration.frontend.website_endpoint
}