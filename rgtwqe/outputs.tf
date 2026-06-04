output "athena_workgroup_names" {
  value = { for k, v in module.athena_workgroup : k => v.name }
}
