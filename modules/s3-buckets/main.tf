resource "aws_s3_bucket" "ed_media_tats" {
    bucket = "ed-media-tats"
    tags = {
      Name = "$(var.bucket_name)ed_media_tats"
    }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.ed_media_tats.id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.ed_media_tats.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.ed_media_tats.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  bucket                = aws_s3_bucket.ed_media_tats.id
  acl                   = "public-read"

  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]
  
}

resource "aws_s3_bucket_policy" "public_policy" {
    bucket = aws_s3_bucket.ed_media_tats.id
    policy = <<EOF
{
    "Id": "SourceIP",
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "SourceIP",
        "Action": "s3:*",
        "Effect": "Deny",
        "Resource": [
          "arn:aws:s3:::ed-media-data-05",
          "arn:aws:s3:::ed-media-data-05/*"
        ],
        "Condition": {
          "NotIpAddress": {
            "aws:SourceIp": [
              "95.151.246.20/32"
            ]
          }
        },
        "Principal": "*"
      }
    ]
  }
EOF
}