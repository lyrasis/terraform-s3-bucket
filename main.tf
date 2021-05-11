resource "aws_s3_bucket" "bucket" {
  bucket = var.name

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  lifecycle_rule {
    id      = "autodelete"
    enabled = true

    expiration {
      days = var.expiration_days
    }
  }

  tags = var.tags
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

resource "aws_iam_access_key" "bucket_reader" {
  user = aws_iam_user.bucket_reader.name
}

resource "aws_iam_user_policy_attachment" "bucket_policy_attach" {
  user       = aws_iam_user.bucket_reader.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}

data "aws_vpc" "provided" {
  id = var.vpc_id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id        = data.aws_vpc.provided.id
  service_name  = "com.amazonaws.${var.region}.s3"

  tags = var.tags
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  route_table_id  = var.route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
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
            "aws:sourceVpce" = aws_vpc_endpoint.s3.id
          }
        }
      },
    ]
  })
}
