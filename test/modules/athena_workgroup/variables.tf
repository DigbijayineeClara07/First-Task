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
  description = "Whether workgroup settings override client-side settings."
  type        = bool
  default     = true
}

variable "publish_cloudwatch_metrics_enabled" {
  description = "Whether CloudWatch metrics are published for queries in this workgroup."
  type        = bool
  default     = true
}

variable "requester_pays_enabled" {
  description = "Whether Amazon S3 requester-pays buckets are enabled for queries."
  type        = bool
  default     = false
}

variable "selected_engine_version" {
  description = "Requested engine version (e.g. AUTO, Athena engine version 3)."
  type        = string
  default     = "AUTO"
}

variable "tags" {
  description = "Tags to apply to the workgroup."
  type        = map(string)
  default     = {}
}
