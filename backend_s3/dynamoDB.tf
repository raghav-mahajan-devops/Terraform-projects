resource "aws_dynamodb_table" "basic_dynamodb_table" {
  name     = var.dynamodb_table_name
  hash_key = var.dynamodb_table_hash_key
  billing_mode = var.dynamodb_table_billing_mode

  attribute {
    name = var.dynamodb_table_attribute_name
    type = "S"
  }

  tags = {
    Name = var.dynamodb_table_name
  }
}