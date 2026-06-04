# Terraform Infrastructure Documentation

**Generation Date**: 2026-06-04  
**Infrastructure Status**: Reconciled (0 changes)  
**Region**: ap-southeast-1 (Singapore)  
**AWS Account**: 714114208215

---

## 1. Overview

This Terraform codebase manages AWS Athena workgroups for the ap-southeast-1 region. The infrastructure was **generated from discovered cloud resources** and **imported into state** until the plan showed zero changes, confirming full reconciliation with the actual cloud configuration.

The discovery process identified one existing Athena workgroup named `primary` in AWS. The code was generated to represent this resource in Terraform, and the workgroup was then imported into state using the provided `imports.sh` script. The final reconciliation shows the infrastructure configuration matches the actual AWS resources exactly.

### What Was Done
1. **Discovery**: Scanned AWS account 714114208215 and found one Athena workgroup (`primary`)
2. **Code Generation**: Created Terraform configuration with a reusable module for Athena workgroups and configured it for the discovered resource
3. **State Import**: Imported the existing workgroup into Terraform state using `terraform import` (via `imports.sh`)
4. **Reconciliation**: Verified with `terraform plan` that no changes are needed (0/0/0)

---

## 2. Resources

### Managed Resources

| Terraform Address | Resource Type | Real-World ID | Purpose |
|---|---|---|---|
| `module.athena_workgroup["primary"].aws_athena_workgroup.this` | `aws_athena_workgroup` | `primary` | Primary Athena workgroup for query execution |

### Resource Details

**Workgroup: primary**
- **ARN**: `arn:aws:athena:ap-southeast-1:714114208215:workgroup/primary`
- **State**: ENABLED
- **Enforce Workgroup Configuration**: false (allows user-level overrides)
- **CloudWatch Metrics**: Enabled (publish_cloudwatch_metrics_enabled = true)
- **Requester Pays**: Disabled
- **Engine Version**: AUTO (automatically selects latest compatible version)
- **Description**: Empty
- **Tags**: None applied

---

## 3. Module Structure

### Local Module: `modules/athena_workgroup/`

This module encapsulates the configuration for a single AWS Athena workgroup.

**File Structure**:
```
modules/athena_workgroup/
├── main.tf         # Defines aws_athena_workgroup.this resource
├── variables.tf    # Input variables for workgroup configuration
└── outputs.tf      # Exports workgroup ARN and ID
```

**Key Components**:

#### `main.tf` - Resource Definition
Defines a single `aws_athena_workgroup` resource with:
- Basic configuration (name, description)
- Configuration block with engine version selection
- CloudWatch metrics publishing control
- Requester pays toggle
- Workgroup enforcement flag
- Tag support

#### `variables.tf` - Inputs (7 variables)
- `name` (required): Workgroup name
- `description`: Optional description (default: empty string)
- `enforce_workgroup_configuration`: Boolean flag (default: true)
- `publish_cloudwatch_metrics_enabled`: Boolean flag (default: true)
- `requester_pays_enabled`: Boolean flag (default: false)
- `selected_engine_version`: Version selection strategy (default: "AUTO")
- `tags`: Map of resource tags (default: empty map)

#### `outputs.tf` - Exports (2 outputs)
- `arn`: The Athena workgroup ARN
- `id`: The workgroup identifier (usually same as name)

### Root Module Configuration

**`main.tf`**: Instantiates the `athena_workgroup` module using `for_each` with the `var.athena_workgroups` map. This allows managing multiple workgroups via a single variable.

**`variables.tf`**: Defines the root-level `athena_workgroups` variable as a map of objects, each containing the configuration for one workgroup.

**`outputs.tf`**: Exports all workgroup ARNs as a map for reference by other stacks or for operational use.

---

## 4. How Import Works

### Import Command Record

The discovered Athena workgroup was imported into Terraform state using the `imports.sh` script:

```bash
tofu import -var-file environments/sg.tfvars \
  'module.athena_workgroup["primary"].aws_athena_workgroup.this' \
  'primary'
```

**Breakdown**:
- **IaC Binary**: OpenTofu (`tofu`) — the binary location is `/tmp/tmp.EoKfhP/tofu`
- **Variable File**: `environments/sg.tfvars` — provides the workgroup configuration
- **Terraform Address**: `module.athena_workgroup["primary"].aws_athena_workgroup.this` — the resource location in the module (using for_each with key "primary")
- **Cloud ID**: `primary` — the name of the workgroup in AWS (used by AWS API to identify the resource)

### What Happened

1. **Discovery**: The workgroup `primary` was discovered as an existing AWS resource
2. **Code Generation**: Terraform code was generated to define this resource
3. **Import**: The existing workgroup state was imported into the Terraform state file, linking the configuration to the actual AWS resource
4. **Reconciliation**: `terraform plan` confirmed zero changes, proving the configuration matches reality

### Re-importing a Single Workgroup (if state is lost)

If Terraform state is accidentally lost but the AWS workgroup still exists, re-import it:

```bash
tofu import -var-file environments/sg.tfvars \
  'module.athena_workgroup["primary"].aws_athena_workgroup.this' \
  'primary'
```

The cloud ID (`primary`) is the workgroup's name in AWS. Obtain it from the AWS Athena console or via CLI:
```bash
aws athena list-work-groups --region ap-southeast-1
```

---

## 5. How to Use the Code

### Prerequisites
- OpenTofu or Terraform installed
- AWS credentials configured (via `~/.aws/credentials` or environment variables)
- Access to AWS account 714114208215 with Athena permissions

### Initialize the Terraform/OpenTofu Working Directory

```bash
cd /mnt/sg_workspace/user/sgcode

# Initialize (downloads provider plugins)
tofu init
```

### View the Plan

```bash
# Dry-run to see what changes would be made
tofu plan -var-file=environments/sg.tfvars
```

Expected output: **No changes.** (confirms reconciliation)

### Apply Changes (if updating configuration)

```bash
# Apply the configuration (creates, updates, or destroys resources as needed)
tofu apply -var-file=environments/sg.tfvars
```

When prompted, type `yes` to confirm.

### Targeting Another Environment

To deploy the same infrastructure to a different environment (e.g., `dev` or `prod`):

1. **Create a new tfvars file** (copy and customize):
   ```bash
   cp environments/sg.tfvars environments/dev.tfvars
   ```

2. **Edit the new file** to change workgroup configuration:
   ```bash
   # environments/dev.tfvars
   athena_workgroups = {
     dev_primary = {
       name                               = "dev-primary"
       description                        = "Development Athena workgroup"
       enforce_workgroup_configuration    = true
       publish_cloudwatch_metrics_enabled = true
       requester_pays_enabled             = false
       selected_engine_version            = "AUTO"
       tags                               = { Environment = "dev" }
     }
   }
   ```

3. **Plan with the new file**:
   ```bash
   tofu plan -var-file=environments/dev.tfvars
   ```

4. **Apply to the new environment**:
   ```bash
   tofu apply -var-file=environments/dev.tfvars
   ```

**Note**: No `.tf` code edits are required — all variations are controlled via tfvars files.

---

## 6. Variables

### Root-Level Variable: `athena_workgroups`

**Type**: `map(object({...}))`

**Description**: A map of Athena workgroup configurations. Keys are arbitrary identifiers (e.g., `"primary"`, `"secondary"`); values define each workgroup's settings.

**Default**: Empty map `{}`

**Example** (from `environments/sg.tfvars`):
```hcl
athena_workgroups = {
  primary = {
    name                               = "primary"
    description                        = ""
    enforce_workgroup_configuration    = false
    publish_cloudwatch_metrics_enabled = true
    requester_pays_enabled             = false
    selected_engine_version            = "AUTO"
    tags                               = {}
  }
}
```

### Variable Schema

Each workgroup object accepts these fields:

| Field | Type | Default | Purpose |
|---|---|---|---|
| `name` | string | (required) | Name of the Athena workgroup (must be unique in region) |
| `description` | string | `""` | Human-readable description |
| `enforce_workgroup_configuration` | bool | `true` | If true, users cannot override workgroup settings; if false, users can override |
| `publish_cloudwatch_metrics_enabled` | bool | `true` | Enable CloudWatch metrics for query execution |
| `requester_pays_enabled` | bool | `false` | If true, query requester pays S3 costs; if false, workgroup/account owner pays |
| `selected_engine_version` | string | `"AUTO"` | Athena engine version: `"AUTO"` (latest), `"ENGINE_VERSION_2"`, `"ENGINE_VERSION_3"` |
| `tags` | map(string) | `{}` | AWS resource tags (e.g., for billing, compliance) |

---

## 7. Infrastructure Graph

```
aws_athena_workgroup.this (module.athena_workgroup["primary"])
├── Configuration
│   ├── enforce_workgroup_configuration: false
│   ├── publish_cloudwatch_metrics_enabled: true
│   ├── requester_pays_enabled: false
│   └── engine_version.selected_engine_version: AUTO
├── Name: primary
├── Description: (empty)
└── Tags: (none)

Dependencies:
├── AWS Region: ap-southeast-1 (provider)
└── AWS Account: 714114208215 (implicit)

Outputs:
├── module.athena_workgroup["primary"].arn
│   └── arn:aws:athena:ap-southeast-1:714114208215:workgroup/primary
└── module.athena_workgroup["primary"].id
    └── primary
```

---

## 8. Notable Decisions & Caveats

### Code Generation Choices

1. **Module-based Design**: The `athena_workgroup` module encapsulates a single resource type, following the "one generic module per resource type" pattern. This allows easy reuse and scaling to multiple workgroups via the root map variable.

2. **for_each Over count**: The root module uses `for_each` on `var.athena_workgroups` (a map) rather than `count` (an index list). This provides stable, descriptive identifiers (`primary`, not `[0]`) and better resilience to reordering.

3. **Configuration Nesting**: Athena workgroup settings are grouped in a `configuration` block in `main.tf`, reflecting AWS API structure. The `engine_version` is nested further as per AWS provider requirements.

4. **Minimal Defaults**: Many workgroup settings are optional with sensible defaults (e.g., `enforce_workgroup_configuration = true`, `publish_cloudwatch_metrics_enabled = true`). These match AWS Athena defaults.

### Omitted/Computed Attributes

The following Athena workgroup attributes were not managed (either computed or service-managed):

| Attribute | Reason |
|---|---|
| `creation_time` | Computed by AWS; read-only |
| `effective_engine_version` | Computed; reflects actual engine running after "AUTO" resolution |
| `state` | Computed by AWS; always "ENABLED" for workgroups in use |
| `output_location` | Query result location (S3); not set in discovered resource—would be configured separately if needed |
| `customer_content_kms_key`, `result_configuration_kms_key` | Encryption keys; not configured in discovered resource |
| `execution_role` | IAM execution role for queries; not configured in discovered resource |
| `bytes_scanned_cutoff_per_query` | Query cost limit; not configured in discovered resource |

These can be added to the module's input variables and `main.tf` if future requirements demand them.

### Reconciliation Status

- **Plan Result**: 0 additions, 0 changes, 0 destructions
- **Drift**: None. The Terraform configuration precisely mirrors the discovered workgroup's actual configuration.
- **State Backend**: Not shown in discovery data (likely uses local state or remote backend configured separately).

### Regional Scope

All resources are in **ap-southeast-1** (Singapore). To use a different region, the provider block in `providers.tf` must be edited or the provider region passed via CLI:
```bash
tofu plan -var-file=environments/sg.tfvars -var "aws_region=us-east-1"
```
(This assumes a root variable `aws_region` is added to enable region switching without code edits.)

---

## Operational Runbook

### Add a New Workgroup

1. Edit `environments/sg.tfvars`:
   ```hcl
   athena_workgroups = {
     primary = { ... },  # existing
     secondary = {
       name                               = "secondary"
       description                        = "Secondary workgroup"
       enforce_workgroup_configuration    = true
       publish_cloudwatch_metrics_enabled = true
       requester_pays_enabled             = false
       selected_engine_version            = "AUTO"
       tags                               = {}
     }
   }
   ```

2. Plan and apply:
   ```bash
   tofu plan -var-file=environments/sg.tfvars
   tofu apply -var-file=environments/sg.tfvars
   ```

### Modify a Workgroup

1. Edit the corresponding key in `environments/sg.tfvars`.
2. Plan to see changes:
   ```bash
   tofu plan -var-file=environments/sg.tfvars
   ```
3. Apply:
   ```bash
   tofu apply -var-file=environments/sg.tfvars
   ```

### Remove a Workgroup

1. Delete the key from `environments/sg.tfvars`.
2. Apply:
   ```bash
   tofu apply -var-file=environments/sg.tfvars
   ```
   Terraform will destroy the corresponding AWS workgroup.

### Retrieve Workgroup ARN

```bash
tofu output athena_workgroup_arns
```

Output:
```json
{
  "primary" = "arn:aws:athena:ap-southeast-1:714114208215:workgroup/primary"
}
```

---

**End of Documentation**
