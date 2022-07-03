# resource "aws_s3_bucket" "gogreen717171" {
#   bucket = "gogreen717171"
#   acl    = "private"
#   versioning {
#     enabled = true
#   }
# }

# # resource "aws_s3_bucket_acl" "bucket_acl" {
# #   bucket = aws_s3_bucket.gogreen717171.id
# #   acl    = "private"
# # }

# resource "aws_s3_bucket_lifecycle_configuration" "gogreen717171" {
#   bucket = aws_s3_bucket.gogreen717171.bucket

#   rule {
#     id = "log"

#     expiration {
#       days = 90
#     }

#     filter {
#       and {
#         prefix = "log/"

#         tags = {
#           rule      = "log"
#           autoclean = "true"
#         }
#       }
#     }

#     status = "Enabled"

#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }

#     transition {
#       days          = 60
#       storage_class = "GLACIER"
#     }
#   }

#   rule {
#     id = "tmp"

#     filter {
#       prefix = "tmp/"
#     }

#     expiration {
#       date = "2027-01-13T00:00:00Z"
#     }

#     status = "Enabled"
#   }
# }
# #Create route53_zone
# resource "aws_route53_zone" "gogreen_aws" {
#   name = "www.gogreen.com"
#   tags = {
#     Environment = "dev"
#   }
# }
# # Creating EIP
# resource "aws_eip" "eip_r53" {
#   vpc = true
# }
# resource "aws_route53_record" "www" {
#   zone_id = aws_route53_zone.gogreen_aws.zone_id
#   name    = "www.gogreen.link"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_eip.eip_r53.public_ip]
# }