output "athena_workgroup_arn" {
  description = "ARN of the primary Athena workgroup"
  value       = module.athena_workgroup.arn
}

output "athena_workgroup_id" {
  description = "ID (name) of the primary Athena workgroup"
  value       = module.athena_workgroup.id
}