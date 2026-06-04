variable "name" {
  type        = string
  description = "Name of the Athena workgroup"
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the workgroup"
}

variable "enforce_workgroup_configuration" {
  type        = bool
  default     = true
  description = "Whether to enforce workgroup configuration"
}

variable "publish_cloudwatch_metrics_enabled" {
  type        = bool
  default     = true
  description = "Whether to publish CloudWatch metrics"
}

variable "requester_pays_enabled" {
  type        = bool
  default     = false
  description = "Whether requester pays is enabled"
}

variable "selected_engine_version" {
  type        = string
  default     = "AUTO"
  description = "Selected engine version"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the workgroup"
}
