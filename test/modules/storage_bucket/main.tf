resource "google_storage_bucket" "this" {
  name                        = var.name
  location                    = var.location
  storage_class               = var.storage_class
  default_event_based_hold    = var.default_event_based_hold
  requester_pays              = var.requester_pays
  uniform_bucket_level_access = var.uniform_bucket_level_access
  labels                      = var.labels

  lifecycle_rule {
    action {
      type = var.lifecycle_rule_action_type
    }
    condition {
      age = var.lifecycle_rule_condition_age
    }
  }
}