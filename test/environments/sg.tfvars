region                       = "US"
name                         = "example-tf-bucket-0edf47ef"
location                     = "US"
storage_class                = "STANDARD"
default_event_based_hold     = false
requester_pays               = false
uniform_bucket_level_access  = false
labels                       = { "goog-terraform-provisioned" = "true" }
versioning_enabled           = false
lifecycle_rule_action_type   = "Delete"
lifecycle_rule_condition_age = 30