# Outputs flow out —
# Workgroup names cross the boundary,
# Others may depend.

output "athena_workgroup_ids" {
  description = "Map of Athena workgroup names by key."
  value       = { for k, m in module.athena_workgroup : k => m.workgroup_name }
}
