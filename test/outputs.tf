output "athena_workgroup_arns" {
  description = "ARNs of the managed Athena workgroups."
  value       = { for k, v in module.athena_workgroup : k => v.arn }
}
