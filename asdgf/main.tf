module "athena_workgroup" {
  source = "./modules/athena_workgroup"

  name                               = var.name
  state                              = var.state
  enforce_workgroup_configuration    = var.enforce_workgroup_configuration
  publish_cloudwatch_metrics_enabled = var.publish_cloudwatch_metrics_enabled
  requester_pays_enabled             = var.requester_pays_enabled
  selected_engine_version            = var.selected_engine_version
}