# Variables declared —
# Each setting named and typed here,
# Defaults keep peace.

variable "name" {
  description = "Name of the Athena workgroup."
  type        = string
}

variable "description" {
  description = "Description of the Athena workgroup."
  type        = string
  default     = ""
}

variable "enforce_workgroup_configuration" {
  description = "Whether to enforce workgroup configuration."
  type        = bool
  default     = true
}

variable "publish_cloudwatch_metrics_enabled" {
  description = "Whether to publish CloudWatch metrics."
  type        = bool
  default     = true
}

variable "requester_pays_enabled" {
  description = "Whether requester pays is enabled."
  type        = bool
  default     = false
}

variable "selected_engine_version" {
  description = "The engine version selected for the workgroup."
  type        = string
  default     = "AUTO"
}

variable "tags" {
  description = "Tags to apply to the workgroup."
  type        = map(string)
  default     = {}
}
