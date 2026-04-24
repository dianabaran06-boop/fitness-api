variable "trainers_table_name" {
  type    = string
  default = "trainers"
}

variable "workouts_table_name" {
  type    = string
  default = "workouts"
}
variable "bucket_name" {
  description = "S3 bucket name for frontend"
  type        = string
}