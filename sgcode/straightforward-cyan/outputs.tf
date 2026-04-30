output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3_bucket.bucket_id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}