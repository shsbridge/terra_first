resource "aws_s3_bucket" "terra_state" {
  bucket = "terra-first-state"

  versioning {
    enabled = true
  }
  
  lifecycle {
    prevent_destroy = false
  }
}
