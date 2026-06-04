# Module outputs speak —
# Name surfaces to the root,
# Wiring made clean.

output "workgroup_name" {
  description = "The name of the Athena workgroup."
  value       = aws_athena_workgroup.this.name
}

output "workgroup_arn" {
  description = "The ARN of the Athena workgroup."
  value       = aws_athena_workgroup.this.arn
}
