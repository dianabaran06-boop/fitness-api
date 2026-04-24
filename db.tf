data "aws_dynamodb_table" "trainers" {
  name = "trainers"
}

data "aws_dynamodb_table" "workouts" {
  name = "workouts"
}