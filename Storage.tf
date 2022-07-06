resource "aws_s3_bucket" "green-supergreen7788" {
  bucket = "green-supergreen7788"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.green-supergreen7788.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "green-supergreen7788" {
  bucket = aws_s3_bucket.green-supergreen7788.bucket

  rule {
    id = "log"

    expiration {
      days = 90
    }

    filter {
      and {
        prefix = "log/"

        tags = {
          rule      = "log"
          autoclean = "true"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }

  rule {
    id = "tmp"

    filter {
      prefix = "tmp/"
    }

    expiration {
      date = "2027-01-13T00:00:00Z"
    }

    status = "Enabled"
  }
}

# #Creating S3bucket
# resource "aws_s3_bucket" "green_supergreen7788" {
#   bucket =  "green-supergreen7788"
#   acl    = "private"
#   lifecycle_rule {
#     id      = "green_supergreen7788_quarterly_retention"
#     prefix  = "folder/"
#     enabled = true
 
#     expiration {
#       days = 90
#     }
#   }
#   versioning {
#     enabled = true
#   }
# }


 
# resource "aws_s3_bucket" "green_supergreen7788_glacier" {
#   bucket = "green_supergreen7788_glacier"
#   acl    = "private"
#   lifecycle_rule {
#     id      = "green_supergreen7788_glacier_fiveyears_retention"
#     prefix  = "folder/"
#     enabled = true
 
#     expiration {
#       days = 1825
#     }
 
#     transition {
#       days          = 1
#       storage_class = "GLACIER"
#     }
#   }
# }
 
# route53domains registered domain
 
# resource "aws_route53domains_registered_domain" "gogreen_aws" {
#   domain_name = "www.gogreen.com"
 
# }
 
#Create route53_zone
 
resource "aws_route53_zone" "gogreen_aws" {
  name = "www.gogreen.link"
 
  tags = {
    Environment = "dev"
  }
}
# Creating EIP
resource "aws_eip" "eip_r53" {
  vpc = true
}
 
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.gogreen_aws.zone_id
  name    = "www.gogreen.link"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.eip_r53.public_ip]
}

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
#   name = "www.gogreen.link"
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