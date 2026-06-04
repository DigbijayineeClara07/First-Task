output "arn" {
  description = "ARN of the Athena workgroup."
  value       = aws_athena_workgroup.this.arn
}

output "id" {
  description = "Name (ID) of the Athena workgroup."
  value       = aws_athena_workgroup.this.id
}
