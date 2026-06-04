resource "aws_athena_workgroup" "this" {
  name  = var.name
  state = var.state

  configuration {
    enforce_workgroup_configuration    = var.enforce_workgroup_configuration
    publish_cloudwatch_metrics_enabled = var.publish_cloudwatch_metrics_enabled
    requester_pays_enabled             = var.requester_pays_enabled

    engine_version {
      selected_engine_version = var.selected_engine_version
    }
  }
}