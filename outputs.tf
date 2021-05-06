# Output variable definitions

output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.bucket.arn
}

output "id" {
  description = "ID of the bucket"
  value       = aws_s3_bucket.bucket.id
}

output "rendered_policy" {
  value = data.aws_iam_policy_document.bucket.json
}
