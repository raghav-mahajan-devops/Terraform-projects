variable "dynamodb_table_name" {
  default = "multi-instance-lock-table"
  type    = string
}
variable "dynamodb_table_hash_key" {
  default = "LockID"
  type    = string
}
variable "dynamodb_table_billing_mode" {
  default = "PAY_PER_REQUEST"
  type    = string
}
variable "dynamodb_table_attribute_name" {
  default = "LockID"
  type    = string
}

variable "bucket_name" {
  default = "terraform-bucket-multi-instance"
  type    = string
}
