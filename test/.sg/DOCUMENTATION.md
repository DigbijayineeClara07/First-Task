# Infrastructure Documentation

## Overview

This Terraform/OpenTofu configuration manages a single AWS Athena workgroup in the `ap-southeast-1` region. The infrastructure was discovered from existing AWS resources, generated as Infrastructure-as-Code, imported into Terraform state, and reconciled until the plan showed zero changes (0/0/0), confirming that the code accurately represents the live resources.

**Region:** ap-southeast-1  
**AWS Account ID:** 714114208215  
**Resource Reconciliation Status:** Complete (no drift)

---

## Resources

| Terraform Address | Provider | Resource Type | Cloud ID | Purpose |
|---|---|---|---|---|
| `module.athena_workgroup["primary"].aws_athena_workgroup.this` | aws | aws_athena_workgroup | `primary` | Primary Athena workgroup for query execution with CloudWatch metrics publishing enabled |

---

## Module Structure

### Root Module

**Location:** `/mnt/sg_workspace/user/sgcode/`

The root module is a thin orchestration layer with no bare resource blocks. It contains:

- **main.tf** — Calls the local `athena_workgroup` module with `for_each` to manage multiple workgroup instances; currently instantiated with the "primary" workgroup
- **variables.tf** — Declares the `athena_workgroups` input variable (map of workgroup configurations)
- **outputs.tf** — Exports `athena_workgroup_arns`, a map of workgroup ARNs indexed by key
- **providers.tf** — Configures AWS provider for `ap-southeast-1`
- **versions.tf** — Specifies Terraform ≥5.0, <6.0 for the AWS provider

### Local Module: `athena_workgroup`

**Location:** `/mnt/sg_workspace/user/sgcode/modules/athena_workgroup/`

Manages a single AWS Athena workgroup instance. Decouples workgroup configuration from root-level orchestration.

**Contents:**

- **main.tf** — Defines `aws_athena_workgroup.this` resource with:
  - Workgroup name, description, and tags
  - Configuration block for enforcement, CloudWatch metrics, requester pays, and engine version selection
  
- **variables.tf** — Input variables:
  - `name` (required) — Workgroup name
  - `description` (optional, default `""`) — Human-readable description
  - `enforce_workgroup_configuration` (optional, default `true`) — Whether workgroup settings override client-side settings
  - `publish_cloudwatch_metrics_enabled` (optional, default `true`) — Enable CloudWatch metrics for queries
  - `requester_pays_enabled` (optional, default `false`) — Allow S3 requester-pays buckets
  - `selected_engine_version` (optional, default `"AUTO"`) — Athena engine version (e.g., "AUTO" or "Athena engine version 3")
  - `tags` (optional, default `{}`) — Resource tags

- **outputs.tf** — Exports:
  - `arn` — ARN of the workgroup
  - `id` — Name/ID of the workgroup

### No External Modules

No pre-built external modules are used. The `aws_athena_workgroup` resource type is managed entirely by the local module.

---

## How Import Works

### Initial Import

The `imports.sh` script was executed once during the discovery and reconciliation phase to populate Terraform state with the existing "primary" workgroup:

```bash
#!/bin/sh
set -e
"$1" import -var-file environments/sg.tfvars 'module.athena_workgroup["primary"].aws_athena_workgroup.this' 'primary'
```

This command:
1. Calls the OpenTofu/Terraform binary (passed as `$1`)
2. Imports the AWS Athena workgroup named `primary` (cloud resource ID)
3. Maps it to the module-qualified Terraform address `module.athena_workgroup["primary"].aws_athena_workgroup.this`
4. Uses the `environments/sg.tfvars` variable file to provide context

**Important:** After successful import and reconciliation, `imports.sh` need not be re-run unless state is completely lost.

### Re-importing a Single Resource

If the Terraform state for the "primary" workgroup is lost or corrupted, re-import it:

```bash
tofu import -var-file environments/sg.tfvars \
  'module.athena_workgroup["primary"].aws_athena_workgroup.this' \
  'primary'
```

Replace `tofu` with `terraform` if using Terraform instead of OpenTofu.

---

## How to Use the Code

### Prerequisites

- OpenTofu ≥1.0 or Terraform ≥1.0
- AWS credentials configured (via environment variables, AWS credentials file, or IAM role)
- The working directory: `/mnt/sg_workspace/user/sgcode`

### Initialize the Backend

```bash
cd /mnt/sg_workspace/user/sgcode
tofu init
```

This command:
- Downloads the AWS provider (≥5.0, <6.0)
- Initializes the backend (default: local state)
- Prepares the modules

### Plan Changes

```bash
tofu plan -var-file=environments/sg.tfvars
```

This shows pending changes. In a reconciled state, output should be:
```
No changes. Your infrastructure matches the configuration.
```

### Apply Changes

```bash
tofu apply -var-file=environments/sg.tfvars
```

Prompts for confirmation before applying. In a reconciled state, no changes are made.

### Targeting a Specific Resource

To plan/apply only the "primary" workgroup:

```bash
tofu plan -var-file=environments/sg.tfvars \
  -target='module.athena_workgroup["primary"].aws_athena_workgroup.this'
```

### Switching Environments (e.g., dev → prod)

To manage another environment or AWS account:

1. **Copy the variables file:**
   ```bash
   cp environments/sg.tfvars environments/prod.tfvars
   ```

2. **Edit the new file to change values:**
   ```bash
   # Edit environments/prod.tfvars
   # Update workgroup names, tags, engine version, metrics settings, etc.
   ```

3. **Plan against the new environment:**
   ```bash
   tofu plan -var-file=environments/prod.tfvars
   ```

4. **Apply (after review):**
   ```bash
   tofu apply -var-file=environments/prod.tfvars
   ```

**Note:** No `.tf` files are edited; all configuration changes flow through the `-var-file` argument. This keeps environments separated and simplifies multi-environment management.

---

## Variables

### Root Module Variables

#### `athena_workgroups` (map of objects)

**Type:** `map(object({...}))`  
**Default:** `{}`  
**Required:** No, but typically provided via `-var-file=environments/sg.tfvars`

Controls which Athena workgroups are created and configured.

**Structure:**
```hcl
athena_workgroups = {
  <key> = {
    name                               = string
    description                        = optional(string)
    enforce_workgroup_configuration    = optional(bool)
    publish_cloudwatch_metrics_enabled = optional(bool)
    requester_pays_enabled             = optional(bool)
    selected_engine_version            = optional(string)
    tags                               = optional(map(string))
  }
}
```

**Example from sg.tfvars:**
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

**Key:** `primary`  
**Purpose:** Creating a workgroup via `for_each` with this key instantiates `module.athena_workgroup["primary"]`.

---

## Infrastructure Graph

```
Root Module (main.tf)
└── module.athena_workgroup["primary"]
    └── aws_athena_workgroup.this
        ├── Name: "primary"
        ├── Description: (empty)
        ├── Enforce Configuration: false
        ├── CloudWatch Metrics: enabled
        ├── Requester Pays: disabled
        └── Engine Version: AUTO
```

**No dependencies or cross-references** between resources (only one resource in this configuration).

---

## Notable Decisions & Caveats

### Design Choices

1. **Local Module Over Direct Resource**  
   The `aws_athena_workgroup` resource is wrapped in a local module (`modules/athena_workgroup/`) to encapsulate configuration logic and allow reusability across multiple workgroups via `for_each`. This follows a modular pattern even though currently only one workgroup exists.

2. **for_each for Horizontal Scaling**  
   The root module uses `for_each = var.athena_workgroups` to instantiate workgroups by key. This allows adding new workgroups by simply appending map entries to `environments/sg.tfvars` without editing `.tf` files.

3. **No Output Configuration Block**  
   The Athena workgroup does not configure result location, encryption, or KMS settings. The workgroup uses AWS defaults (e.g., CloudWatch metrics publishing defaults to the account setting). These can be added to the module's configuration block if needed in future updates.

4. **CloudWatch Metrics Enabled**  
   The discovered workgroup publishes CloudWatch metrics. The configuration enforces this via `publish_cloudwatch_metrics_enabled = true` in `sg.tfvars`.

### Omitted Attributes

The following computed/discovered attributes are not managed (read-only or not exposed in variables):

- `bytes_scanned_cutoff_per_query` — Query cost limit (null in discovery; not exposed)
- `customer_content_kms_key` — KMS key for workspace-level encryption (null; not managed)
- `result_configuration_kms_key` — KMS key for result output (null; not managed)
- `output_location` — S3 bucket for query results (null; not managed)
- `execution_role` — IAM role for query execution (null; not managed)
- `creation_time` — Auto-managed AWS timestamp
- `effective_engine_version` — Computed by AWS based on `selected_engine_version`
- `state` — Workgroup lifecycle state (auto-enabled on creation)

These can be added to the module if required; update `modules/athena_workgroup/variables.tf` and `main.tf` accordingly.

### Current Reconciliation State

✅ **Zero drift.** The plan showed no changes:
- The configuration in `environments/sg.tfvars` matches the live workgroup in AWS
- The imported resource is fully managed by Terraform state
- All attributes exposed in variables match discovered values

---

## File Structure

```
/mnt/sg_workspace/user/sgcode/
├── main.tf                      # Root module orchestration
├── variables.tf                 # Root input variables
├── outputs.tf                   # Root outputs
├── providers.tf                 # AWS provider configuration
├── versions.tf                  # Provider version constraints
├── imports.sh                   # One-time import script (historical record)
├── environments/
│   └── sg.tfvars               # Variable values for this environment
├── modules/
│   └── athena_workgroup/
│       ├── main.tf             # Workgroup resource definition
│       ├── variables.tf         # Module input variables
│       └── outputs.tf           # Module outputs
└── .sg/
    ├── DOCUMENTATION.md         # This file
    └── validation.json         # Reconciliation metadata
```

---

## Troubleshooting

### State Mismatch or Loss

If `tofu plan` shows unexpected changes or state is corrupted:

1. **Verify the current state:**
   ```bash
   tofu state list
   ```
   Should show: `module.athena_workgroup["primary"].aws_athena_workgroup.this`

2. **Re-import if necessary:**
   ```bash
   tofu import -var-file=environments/sg.tfvars \
     'module.athena_workgroup["primary"].aws_athena_workgroup.this' \
     'primary'
   ```

3. **Plan again:**
   ```bash
   tofu plan -var-file=environments/sg.tfvars
   ```

### Provider Issues

Ensure AWS credentials are available:
```bash
export AWS_PROFILE=<your-profile>  # or AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY
tofu init
tofu plan -var-file=environments/sg.tfvars
```

### Drift Detection

To detect drift between state and live resources:
```bash
tofu refresh -var-file=environments/sg.tfvars
tofu plan -var-file=environments/sg.tfvars
```

If drift is detected, either:
- Update `environments/sg.tfvars` to match the desired state, then apply
- Import the resource again to sync state

---

**Generated:** 2026-06-04  
**IaC Tool:** OpenTofu / Terraform ≥5.0  
**AWS Provider Version:** ≥5.0, <6.0  
**Region:** ap-southeast-1

