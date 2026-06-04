variable "athena_workgroups" {
  description = "Map of Athena workgroup instances to manage."
  type = map(object({
    name                               = string
    description                        = optional(string, "")
    enforce_workgroup_configuration    = optional(bool, true)
    publish_cloudwatch_metrics_enabled = optional(bool, true)
    requester_pays_enabled             = optional(bool, false)
    selected_engine_version            = optional(string, "AUTO")
    tags                               = optional(map(string), {})
  }))
  default = {}
}
