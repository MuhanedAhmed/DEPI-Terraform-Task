# resource "aws_s3_bucket" "s3-backend" {
#   bucket = "depi-terraform-task"

#   force_destroy = true
#   tags = {
#     Environment = "Task"
#   }
# }



# resource "aws_dynamodb_table" "dynamodb-backend" {
#   name           = "depi-terraform-task"
#   billing_mode   = "PROVISIONED"
#   read_capacity  = 20
#   write_capacity = 20
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     Environment = "Task"
#   }
# }