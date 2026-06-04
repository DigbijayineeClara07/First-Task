# Infrastructure Documentation: Athena Workgroup

## 1. Overview

This Terraform/OpenTofu code manages a single AWS Athena workgroup in the `ap-southeast-1` region. The infrastructure was **generated from discovered cloud resources**, imported into Terraform state, and reconciled until `plan` showed no changes (0 to add, 0 to change, 0 to destroy). The state now matches the configuration exactly.

**Scope:**
- 1 AWS Athena workgroup: `primary`
- Region: `ap-southeast-1`
- AWS Account: `714114208215`
- State backend: Local (default)

## 2. Resources

| Terraform Address | Provider Type | Real-World Name/ID | Purpose |
|---|---|---|---|
| `module.athena_workgroup["primary"].aws_athena_workgroup.this` | `aws_athena_workgroup` | `primary` | Athena SQL query workgroup with CloudWatch metrics enabled, requester pays disabled, and AUTO engine version selection. Enforces workgroup configuration disabled to allow query-level overrides. |

## 3. Module Structure

### Root Module
**Location:** `/mnt/sg_workspace/user/sgcode/`

**Files:**
- `versions.tf` — Terraform version constraints and required AWS provider
- `providers.tf` — AWS provider configuration (region: `ap-southeast-1`)
- `variables.tf` — Root-level input: `var.athena_workgroups` (map of workgroup objects)
- `outputs.tf` — Exports `athena_workgroup_ids` (map of workgroup names)
- `main.tf` — Module instantiation using `for_each` over `var.athena_workgroups`

### Local Module: `modules/athena_workgroup/`
**Purpose:** Encapsulates the creation and configuration of a single AWS Athena workgroup.

**Files:**
- `main.tf` — Defines `aws_athena_workgroup.this` with configuration block for engine version, metrics, and enforcement settings
- `variables.tf` — Module inputs (name, description, state, CloudWatch metrics, requester pays, engine version, tags)
- `outputs.tf` — Exports `id` (workgroup name/ID)

**Call Style:** `for_each` loop in root `main.tf`
- Each map key (e.g., `primary`) becomes the `for_each` iteration key
- Access pattern: `module.athena_workgroup["primary"].aws_athena_workgroup.this`
- Supports multiple workgroups by adding more keys to `var.athena_workgroups`

## 4. How Import Works

### Import Process
The `imports.sh` script performs a one-time import to populate Terraform state from discovered cloud resources:

```bash
#!/bin/sh
set -e
"$1" import -var-file environments/sg.tfvars 'module.athena_workgroup["primary"].aws_athena_workgroup.this' 'primary'
```

**What happened:**
1. The script was executed once (likely during initial reconciliation) with the OpenTofu/Terraform binary as `$1`
2. The resource at cloud ID `primary` was imported into the state at address `module.athena_workgroup["primary"].aws_athena_workgroup.this`
3. The `-var-file` flag ensured variables matched the deployed values
4. State is now authoritative; re-running imports is **not required** unless state is lost or corrupted

### Re-importing a Single Resource (if needed)
If state is lost or corrupted, re-import the workgroup:

```bash
/tmp/tmp.nlmCbj/tofu import -var-file environments/sg.tfvars \
  'module.athena_workgroup["primary"].aws_athena_workgroup.this' \
  'primary'
```

The cloud ID is the workgroup name: `primary`.

## 5. How to Use the Code

### Initialize Terraform/OpenTofu
```bash
cd /mnt/sg_workspace/user/sgcode
/tmp/tmp.nlmCbj/tofu init
```

### Plan Changes
Review what will be applied without making changes:

```bash
/tmp/tmp.nlmCbj/tofu plan -var-file=environments/sg.tfvars
```

Expected output after reconciliation: `No changes. Your infrastructure matches the configuration.`

### Apply Changes
Deploy the infrastructure (idempotent if plan shows 0 changes):

```bash
/tmp/tmp.nlmCbj/tofu apply -var-file=environments/sg.tfvars
```

### Targeting Another Environment
To deploy to a different environment (e.g., `dev` or `prod`):

1. **Copy the tfvars file:**
   ```bash
   cp environments/sg.tfvars environments/dev.tfvars
   ```

2. **Edit the new file to set environment-specific values:**
   ```hcl
   athena_workgroups = {
     primary = {
       name                               = "primary-dev"  # Different name for dev
       description                        = "Dev workgroup"
       state                              = "ENABLED"
       enforce_workgroup_configuration    = false
       publish_cloudwatch_metrics_enabled = true
       requester_pays_enabled             = false
       selected_engine_version            = "AUTO"
       tags                               = { env = "dev" }
     }
   }
   ```

3. **Plan and apply with the new file (no `.tf` edits required):**
   ```bash
   /tmp/tmp.nlmCbj/tofu plan -var-file=environments/dev.tfvars
   /tmp/tmp.nlmCbj/tofu apply -var-file=environments/dev.tfvars
   ```

**Key principle:** All infrastructure variation flows through `*.tfvars` files; the `.tf` code remains environment-agnostic.

## 6. Variables

### Root Variable: `athena_workgroups`

**Type:** `map(object({...}))`

**Description:** Map of Athena workgroups to manage. Each key is a workgroup identifier; each value is a workgroup configuration object.

**Object Schema:**
| Field | Type | Required | Default | Purpose |
|---|---|---|---|---|
| `name` | `string` | ✓ | — | Name of the Athena workgroup (must be unique within region) |
| `description` | `string` | ✗ | `""` | Human-readable description of the workgroup |
| `state` | `string` | ✗ | `"ENABLED"` | Workgroup state (`ENABLED` or `DISABLED`) |
| `enforce_workgroup_configuration` | `bool` | ✗ | `true` | If `true`, workgroup settings override client-side query settings; if `false`, client settings take precedence |
| `publish_cloudwatch_metrics_enabled` | `bool` | ✗ | `true` | Publish CloudWatch metrics for queries executed in this workgroup |
| `requester_pays_enabled` | `bool` | ✗ | `false` | Enable requester pays mode (requester pays S3 query result storage) |
| `selected_engine_version` | `string` | ✗ | `"AUTO"` | Athena engine version (`AUTO`, `AUTO_LATEST`, or a specific version number) |
| `tags` | `map(string)` | ✗ | `{}` | AWS resource tags |

**Current value (from `environments/sg.tfvars`):**
```hcl
athena_workgroups = {
  primary = {
    name                               = "primary"
    description                        = ""
    state                              = "ENABLED"
    enforce_workgroup_configuration    = false
    publish_cloudwatch_metrics_enabled = true
    requester_pays_enabled             = false
    selected_engine_version            = "AUTO"
    tags                               = {}
  }
}
```

### Module Outputs

**`athena_workgroup_ids`:** Map of workgroup keys to their IDs. Example:
```hcl
{
  primary = "primary"
}
```

Access in root module outputs:
```hcl
resource "..." "..." {
  some_attribute = module.athena_workgroup["primary"].id
}
```

## 7. Infrastructure Graph

```
root (var.athena_workgroups)
└── module.athena_workgroup (for_each)
    └── module.athena_workgroup["primary"]
        └── aws_athena_workgroup.this
            ├── name: "primary"
            ├── state: "ENABLED"
            ├── enforce_workgroup_configuration: false
            ├── configuration.publish_cloudwatch_metrics_enabled: true
            ├── configuration.requester_pays_enabled: false
            └── configuration.engine_version.selected_engine_version: "AUTO"
```

**Notes:**
- No external dependencies (e.g., S3 buckets, KMS keys) are managed or referenced
- The workgroup is standalone; it does not require result configuration (output location) to be set
- Metrics are published to CloudWatch under the workgroup name namespace

## 8. Notable Decisions & Caveats

### Explicit Arguments (Not Purely Computed)
- **`enforce_workgroup_configuration = false`** — AWS provider defaults to `true`, but discovery found `false`. This is explicitly set in the resource to prevent drift on subsequent plans. If omitted, Terraform would attempt to change it to `true`.
- **`state = "ENABLED"`** — Included as an explicit argument, even though it is the default, for clarity and to ensure state matches expectations.

### Omitted Computed Attributes
The following attributes were discovered as `null` and are intentionally omitted from the resource definition to reduce noise and avoid spurious diffs:

- **`bytes_scanned_cutoff_per_query`** — Not set; workgroup has no scanning quota
- **`execution_role`** — Not set; no IAM execution role specified
- **`customer_content_kms_key`** — Not set; no customer-managed KMS encryption for customer content
- **`result_configuration`** block — Omitted entirely (all sub-attributes were `null`):
  - `output_location` (S3 path for query results) — not specified
  - `encryption_option` — not set
  - `result_configuration_kms_key` — not set

### No `lifecycle` Blocks
No `lifecycle { ignore_changes }` blocks are needed because:
- No write-only attributes are present (all arguments are settable)
- No ephemeral/auto-populating fields require special handling
- The workgroup's computed fields (e.g., `creation_time`, `effective_engine_version`) do not drift and do not need to be ignored

### Tags
Tags are empty (`{}`). If future compliance or cost-tracking requires tags, update `environments/sg.tfvars` to add them to the `tags` object.

### Reconciliation Status
✓ **All infrastructure matches the configuration.** State has been imported, and `plan` output shows 0 to add, 0 to change, 0 to destroy. No unmanaged drift detected.

