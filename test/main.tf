module "storage_bucket" {
  source = "./modules/storage_bucket"

  name                         = var.name
  location                     = var.location
  storage_class                = var.storage_class
  default_event_based_hold     = var.default_event_based_hold
  requester_pays               = var.requester_pays
  uniform_bucket_level_access  = var.uniform_bucket_level_access
  labels                       = var.labels
  versioning_enabled           = var.versioning_enabled
  lifecycle_rule_action_type   = var.lifecycle_rule_action_type
  lifecycle_rule_condition_age = var.lifecycle_rule_condition_age
}