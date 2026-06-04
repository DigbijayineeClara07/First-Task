output "athena_workgroup_ids" {
  description = "Map of Athena workgroup names"
  value       = { for k, m in module.athena_workgroup : k => m.id }
}
