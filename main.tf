resource "aws_s3_bucket" "bucket" {
  bucket = var.name

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  tags = var.tags
}


data "aws_iam_policy_document" "bucket" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.bucket.arn]
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
