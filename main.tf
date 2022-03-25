resource "aws_s3_bucket" "bucket" {
  bucket = var.name
  tags = var.tags
}

resource "aws_s3_bucket_acl" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current_user.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current_user.id
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "autodelete"
    status = var.expiration_days > 0 ? "Enabled" : "Disabled"

    expiration {
      days = var.expiration_days
    }
  }
}

data "aws_iam_policy_document" "bucket" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl",
    ]
    resources = [aws_s3_bucket.bucket.arn,"${aws_s3_bucket.bucket.arn}/*"]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "bucket_policy" {
  name        = "${var.name}-policy"
  description = "${var.name} S3 policy"
  policy = data.aws_iam_policy_document.bucket.json
}

data "aws_canonical_user_id" "current_user" {}

resource "aws_iam_user" "bucket_reader" {
  name = "${var.name}-reader"

  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "bucket_policy_attach" {
  user       = aws_iam_user.bucket_reader.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}

data "aws_vpc" "provided" {
  id = var.vpc_id
}

data "aws_vpc_endpoint" "s3" {
  vpc_id        = data.aws_vpc.provided.id
  service_name  = "com.amazonaws.${var.region}.s3"
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.name}-VPCE-Policy"
    Statement = [
      {
        Sid       = "Access-to-specific-VPCE-only"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.bucket.arn,
          "${aws_s3_bucket.bucket.arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = data.aws_vpc_endpoint.s3.id
          }
        }
      },
    ]
  })
}
