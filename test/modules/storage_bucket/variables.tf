variable "name" {
  type        = string
  description = "The name of the GCS bucket"
}

variable "location" {
  type        = string
  description = "The GCS location for the bucket"
}

variable "storage_class" {
  type        = string
  description = "The storage class of the bucket"
}

variable "default_event_based_hold" {
  type        = bool
  description = "Whether to automatically apply an eventBasedHold to new objects"
}

variable "requester_pays" {
  type        = bool
  description = "Whether requester pays is enabled"
}

variable "uniform_bucket_level_access" {
  type        = bool
  description = "Whether uniform bucket-level access is enabled"
}

variable "labels" {
  type        = map(string)
  description = "Labels to assign to the bucket"
}

variable "versioning_enabled" {
  type        = bool
  description = "Whether versioning is enabled for the bucket"
}

variable "lifecycle_rule_action_type" {
  type        = string
  description = "The action type for the lifecycle rule"
}

variable "lifecycle_rule_condition_age" {
  type        = number
  description = "Minimum age in days for the lifecycle rule condition"
}