# athena-workgroup-primary

## Description

Manages an AWS Athena workgroup named `primary` in the `ap-southeast-1` region.

## Module Overview

| Module | Description |
|--------|-------------|
| `athena_workgroup` | Manages the primary Athena workgroup and its configuration |

## Variables Reference

| Name | Type | Description | Default |
|------|------|-------------|---------|
| `region` | `string` | AWS region where resources will be managed | — |
| `name` | `string` | Name of the Athena workgroup | — |
| `state` | `string` | State of the workgroup. Valid values are `DISABLED` or `ENABLED` | — |
| `enforce_workgroup_configuration` | `bool` | Whether the settings for the workgroup override client-side settings | — |
| `publish_cloudwatch_metrics_enabled` | `bool` | Whether Amazon CloudWatch metrics are enabled for the workgroup | — |
| `requester_pays_enabled` | `bool` | Whether members can reference Amazon S3 Requester Pays buckets in queries | — |
| `selected_engine_version` | `string` | Requested Athena engine version | — |

## Outputs Reference

| Name | Description |
|------|-------------|
| `athena_workgroup_arn` | ARN of the primary Athena workgroup |
| `athena_workgroup_id` | ID (name) of the primary Athena workgroup |

## Usage Instructions

### 1. Initialize

```sh
tofu init
```

### 2. Import existing resources

```sh
chmod +x imports.sh
./imports.sh tofu
```

### 3. Plan

```sh
tofu plan -var-file environments/sg.tfvars
```

### 4. Apply

```sh
tofu apply -var-file environments/sg.tfvars
```