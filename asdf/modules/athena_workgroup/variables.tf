variable "name" {
  type        = string
  description = "Name of the Athena workgroup"
}

variable "state" {
  type        = string
  description = "State of the workgroup. Valid values are DISABLED or ENABLED"
}

variable "enforce_workgroup_configuration" {
  type        = bool
  description = "Whether the settings for the workgroup override client-side settings"
}

variable "publish_cloudwatch_metrics_enabled" {
  type        = bool
  description = "Whether Amazon CloudWatch metrics are enabled for the workgroup"
}

variable "requester_pays_enabled" {
  type        = bool
  description = "Whether members can reference Amazon S3 Requester Pays buckets in queries"
}

variable "selected_engine_version" {
  type        = string
  description = "Requested Athena engine version"
}