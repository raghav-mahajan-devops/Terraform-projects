resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "${var.env}-terraform-bucket-raghav"
}