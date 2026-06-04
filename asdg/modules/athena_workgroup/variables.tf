variable "name" {
  description = "Name of the Athena workgroup"
  type        = string
}

variable "description" {
  description = "Description of the workgroup"
  type        = string
  default     = ""
}

variable "state" {
  description = "State of the workgroup (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"
}

variable "enforce_workgroup_configuration" {
  description = "Whether workgroup settings override client-side settings"
  type        = bool
  default     = true
}

variable "publish_cloudwatch_metrics_enabled" {
  description = "Whether CloudWatch metrics are published for queries in this workgroup"
  type        = bool
  default     = true
}

variable "requester_pays_enabled" {
  description = "Whether requester pays is enabled"
  type        = bool
  default     = false
}

variable "selected_engine_version" {
  description = "Requested engine version"
  type        = string
  default     = "AUTO"
}

variable "tags" {
  description = "Tags to apply to the workgroup"
  type        = map(string)
  default     = {}
}
