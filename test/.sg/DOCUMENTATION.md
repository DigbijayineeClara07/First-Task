# gcs-storage-bucket

## Description

Google Cloud Storage bucket with lifecycle rules. This stack provisions a single GCS bucket with configurable storage class, versioning, labels, and a lifecycle delete rule based on object age.

## Module Overview

| Module | Source | Description |
|--------|--------|-------------|
| `storage_bucket` | `./modules/storage_bucket` | Manages a Google Cloud Storage bucket with lifecycle delete rule |

## Resources

| Resource Type | Logical Name | Description |
|---------------|--------------|-------------|
| `google_storage_bucket` | `this` | The GCS bucket |

## Variables Reference

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `region` | `string` | — | The region for the provider |
| `name` | `string` | — | The name of the GCS bucket |
| `location` | `string` | — | The GCS location for the bucket |
| `storage_class` | `string` | — | The storage class of the bucket |
| `default_event_based_hold` | `bool` | — | Whether to automatically apply an eventBasedHold to new objects |
| `requester_pays` | `bool` | — | Whether requester pays is enabled |
| `uniform_bucket_level_access` | `bool` | — | Whether uniform bucket-level access is enabled |
| `labels` | `map(string)` | — | Labels to assign to the bucket |
| `versioning_enabled` | `bool` | — | Whether versioning is enabled for the bucket |
| `lifecycle_rule_action_type` | `string` | — | The action type for the lifecycle rule |
| `lifecycle_rule_condition_age` | `number` | — | Minimum age in days for the lifecycle rule condition |

## Outputs Reference

| Name | Description |
|------|-------------|
| `bucket_name` | The name of the GCS bucket |
| `bucket_self_link` | The self link of the GCS bucket |
| `bucket_url` | The base URL of the GCS bucket |

## Usage Instructions

### 1. Initialize

```sh
terraform init
```

### 2. Import existing resources

```sh
./imports.sh terraform
# or with OpenTofu:
./imports.sh tofu
```

### 3. Plan

```sh
terraform plan -var-file environments/sg.tfvars
```

### 4. Apply

```sh
terraform apply -var-file environments/sg.tfvars
```

## Notes

- The bucket is imported using its name: `example-tf-bucket-0edf47ef`.
- After import, run `terraform plan` to verify zero drift before applying any changes.
- `force_destroy` is not set (defaults to `false`), consistent with the imported state.