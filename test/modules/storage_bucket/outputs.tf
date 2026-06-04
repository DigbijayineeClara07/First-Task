output "bucket_name" {
  description = "The name of the GCS bucket"
  value       = google_storage_bucket.this.name
}

output "bucket_self_link" {
  description = "The self link of the GCS bucket"
  value       = google_storage_bucket.this.self_link
}

output "bucket_url" {
  description = "The base URL of the GCS bucket"
  value       = google_storage_bucket.this.url
}