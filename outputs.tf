output "trainers_table_arn" {
  value = data.aws_dynamodb_table.trainers.arn
}


output "workouts_table_arn" {
  value = data.aws_dynamodb_table.workouts.arn
}

output "api_url" {
  value = aws_api_gateway_stage.dev.invoke_url
}