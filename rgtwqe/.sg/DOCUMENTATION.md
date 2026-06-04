# Terraform/OpenTofu Infrastructure Documentation

**Generated:** 2026-06-04  
**Reconciliation Status:** ✓ Clean (No changes — infrastructure matches configuration)

---

## 1. Overview

This Terraform configuration manages AWS Athena workgroups in the `ap-southeast-1` region. The code was generated from discovered cloud resources (specifically one Athena workgroup named "primary"), imported into Terraform state via `imports.sh`, and subsequently reconciled until `terraform plan` showed zero changes (0 to add, 0 to change, 0 to destroy).

### What It Does
- **Discovers** a production Athena workgroup from AWS account `714114208215`
- **Generates** Terraform code to represent it declaratively
- **Imports** the actual resource into state without modification
- **Reconciles** configuration to ensure the code matches live state exactly

The infrastructure is now managed entirely through this code and version control.

---

## 2. Resources

| Terraform Address | Resource Type | Real-World ID | Purpose |
|-------------------|---------------|---------------|---------|
| `module.athena_workgroup["primary"].aws_athena_workgroup.this` | `aws_athena_workgroup` | `primary` | Primary Athena query workgroup for the account, configured for CloudWatch metrics publishing |

**Resource Details:**
- **Name:** `primary`
- **Description:** (empty string)
- **Region:** `ap-southeast-1`
- **Account ID:** `714114208215`
- **ARN:** `arn:aws:athena:ap-southeast-1:714114208215:workgroup/primary`
- **State:** ENABLED
- **CloudWatch Metrics:** Enabled
- **Requester Pays:** Disabled
- **Configuration Enforcement:** Disabled (allows per-user overrides)
- **Engine Version:** AUTO (automatic Athena engine selection)
- **Tags:** (empty)

---

## 3. Module Structure

### Root Module
**Location:** `/mnt/sg_workspace/user/sgcode/`

**Files:**
- `main.tf` — Calls `module.athena_workgroup` with `for_each` over workgroup configurations
- `variables.tf` — Declares `var.athena_workgroups` (map of workgroup configurations)
- `outputs.tf` — Exports workgroup names via `athena_workgroup_names` output
- `providers.tf` — Configures the AWS provider for `ap-southeast-1`
- `versions.tf` — Specifies required provider (hashicorp/aws, no pinned version)
- `imports.sh` — Shell script to import the discovered workgroup into state

**Root Call Pattern:**
```hcl
module "athena_workgroup" {
  source   = "./modules/athena_workgroup"
  for_each = var.athena_workgroups
  
  name                               = each.value.name
  description                        = each.value.description
  enforce_workgroup_configuration    = each.value.enforce_workgroup_configuration
  publish_cloudwatch_metrics_enabled = each.value.publish_cloudwatch_metrics_enabled
  requester_pays_enabled             = each.value.requester_pays_enabled
  selected_engine_version            = each.value.selected_engine_version
  tags                               = each.value.tags
}
```

### Local Module: `athena_workgroup`
**Location:** `/mnt/sg_workspace/user/sgcode/modules/athena_workgroup/`

**Purpose:** Encapsulates AWS Athena workgroup creation and configuration.

**Files:**
- `main.tf` — Defines `aws_athena_workgroup.this` resource
- `variables.tf` — Accepts name, description, configuration flags, engine version, and tags
- `outputs.tf` — Exports workgroup `name` and `arn`

**Resource Created:**
- `aws_athena_workgroup.this` — One instance per `for_each` key in the root call

**Module Inputs (All Optional Except `name`):**
| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `name` | `string` | (required) | Workgroup name |
| `description` | `string` | `""` | Short description |
| `enforce_workgroup_configuration` | `bool` | `true` | Enforce this workgroup's config on all users |
| `publish_cloudwatch_metrics_enabled` | `bool` | `true` | Publish query metrics to CloudWatch |
| `requester_pays_enabled` | `bool` | `false` | Enable requester-pays queries |
| `selected_engine_version` | `string` | `"AUTO"` | Athena engine version (AUTO for latest) |
| `tags` | `map(string)` | `{}` | AWS tags |

**Module Outputs:**
| Output | Type | Source |
|--------|------|--------|
| `name` | `string` | `aws_athena_workgroup.this.name` |
| `arn` | `string` | `aws_athena_workgroup.this.arn` |

---

## 4. How Import Works

### Initial Import Process

The `imports.sh` script was executed once during stack initialization to populate Terraform state with the discovered "primary" workgroup:

```bash
./imports.sh /tmp/tmp.ajeljp/tofu
```

**What It Does:**
```sh
#!/bin/sh
set -e
"$1" import -var-file environments/sg.tfvars 'module.athena_workgroup["primary"].aws_athena_workgroup.this' 'primary'
```

1. Takes the IaC binary path (OpenTofu or Terraform) as `$1`
2. Runs `import` with the variable file to provide workgroup configuration
3. Maps the Athena workgroup ID `"primary"` to the state address `module.athena_workgroup["primary"].aws_athena_workgroup.this`

**State After Import:**
- The "primary" workgroup now exists in `terraform.tfstate`
- Configuration values from `environments/sg.tfvars` match the live resource exactly
- `terraform plan` shows zero changes

### Re-importing a Single Resource

If state is lost or corrupted, re-import the workgroup without re-running all infrastructure:

```bash
/tmp/tmp.ajeljp/tofu import -var-file environments/sg.tfvars \
  'module.athena_workgroup["primary"].aws_athena_workgroup.this' \
  'primary'
```

**Note:** This only refreshes state; it does not modify the workgroup itself. The workgroup must already exist in AWS.

---

## 5. How to Use the Code

### Prerequisites
- OpenTofu or Terraform installed and in `PATH`
- AWS credentials configured (via environment variables, `~/.aws/credentials`, or IAM role)
- Working directory: `/mnt/sg_workspace/user/sgcode`

### Initialization

Initialize Terraform/OpenTofu to download providers:

```bash
cd /mnt/sg_workspace/user/sgcode
/tmp/tmp.ajeljp/tofu init
```

Or, if using Terraform:
```bash
terraform init
```

### View Current Configuration

```bash
/tmp/tmp.ajeljp/tofu plan -var-file=environments/sg.tfvars
```

Expected output: `No changes. Infrastructure matches configuration.`

### Apply Changes

To deploy any pending changes:

```bash
/tmp/tmp.ajeljp/tofu apply -var-file=environments/sg.tfvars
```

Review the plan, then confirm with `yes`.

### Targeting a Different Environment

To deploy to a different environment (e.g., dev vs. prod):

1. **Create a new variable file:**
   ```bash
   cp environments/sg.tfvars environments/dev.tfvars
   ```

2. **Edit the new file with environment-specific values:**
   ```hcl
   # environments/dev.tfvars
   athena_workgroups = {
     primary = {
       name                               = "primary-dev"
       description                        = "Dev workgroup"
       enforce_workgroup_configuration    = false
       publish_cloudwatch_metrics_enabled = true
       requester_pays_enabled             = false
       selected_engine_version            = "AUTO"
       tags                               = { Environment = "dev" }
     }
   }
   ```

3. **Plan with the new file:**
   ```bash
   /tmp/tmp.ajeljp/tofu plan -var-file=environments/dev.tfvars
   ```

4. **Apply (if ready):**
   ```bash
   /tmp/tmp.ajeljp/tofu apply -var-file=environments/dev.tfvars
   ```

**No `.tf` code changes required** — all environment differences are managed via variable files.

### Destroy Infrastructure

To remove all managed resources:

```bash
/tmp/tmp.ajeljp/tofu destroy -var-file=environments/sg.tfvars
```

---

## 6. Variables

### Root-Level Variable: `athena_workgroups`

**Type:** `map(object({...}))`

**Default:** `{}`

**Description:** Map of Athena workgroup configurations, keyed by workgroup name (or identifier).

**Structure:**
```hcl
athena_workgroups = {
  <key> = {
    name                               = string
    description                        = optional(string, "")
    enforce_workgroup_configuration    = optional(bool, true)
    publish_cloudwatch_metrics_enabled = optional(bool, true)
    requester_pays_enabled             = optional(bool, false)
    selected_engine_version            = optional(string, "AUTO")
    tags                               = optional(map(string), {})
  }
  ...
}
```

**Current Value (from `environments/sg.tfvars`):**
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

**To Add Another Workgroup:**
Add a new key to the map in your `.tfvars` file:
```hcl
athena_workgroups = {
  primary = { ... },
  secondary = {
    name                               = "secondary"
    description                        = "Secondary workgroup for data analysts"
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    requester_pays_enabled             = false
    selected_engine_version            = "AUTO"
    tags                               = { Team = "Analytics" }
  }
}
```

Then plan and apply — the new workgroup module instance will be created.

---

## 7. Infrastructure Graph

```
Root Module (ap-southeast-1)
├── module.athena_workgroup["primary"]
│   └── aws_athena_workgroup.this
│       └── (no internal dependencies)
│
├── outputs
│   └── athena_workgroup_names
│       └── references: module.athena_workgroup[*].name
│
└── provider: aws (ap-southeast-1)
```

**Cross-Module References:**
- None (single-resource stack with no inter-resource dependencies)

**External References:**
- AWS account `714114208215` in region `ap-southeast-1`

---

## 8. Notable Decisions & Caveats

(From `.sg/handoff.md`)

### Design Decisions

1. **`enforce_workgroup_configuration = false`**
   - Matches the live workgroup state exactly
   - Default in the module is `true`, but the discovered resource has it disabled
   - Set intentionally to `false` in `sg.tfvars` to match current behavior

2. **`selected_engine_version = "AUTO"`**
   - Maps to the nested `engine_version { selected_engine_version }` block
   - Allows Athena to automatically use the latest compatible engine version
   - No hardcoded engine version pinning required

3. **Omitted Computed Attributes**
   - `state` (ENABLED) — computed at creation time; cannot be set directly
   - `output_location` (null) — omitted entirely; can be configured later via Athena console or separate `aws_athena_workgroup_state` resource if needed
   - `encryption_option` (null) — omitted; no encryption configuration required for this workgroup
   - `creation_time` — always computed; not managed

4. **Empty Tags**
   - Tags are `{}` in the discovery output
   - Matched exactly in code; no default tags applied
   - Add tags via `sg.tfvars` if tagging strategy is adopted

5. **Local Module Layout**
   - One local module (`modules/athena_workgroup/`) per resource type (`aws_athena_workgroup`)
   - Called from root with `for_each` to support multiple workgroups in the future
   - No external (git::) modules used; all code is self-contained

### Lifecycle & Ignore Changes

- **None applied** — the resource definition matches live state exactly after import
- Future changes to the live workgroup (e.g., via console) will be detected by `terraform plan`

### Known Limitations / Future Considerations

- **Result Configuration (Output Location):** Currently not configured. If needed, add a `result_configuration` block to specify S3 output location and optional KMS encryption.
- **Requester Pays:** Currently disabled. Enable only if cross-account queries are required.
- **CloudWatch Metrics:** Currently enabled. This incurs CloudWatch charges; disable if not needed.

### Reconciliation Status

✓ **Clean:** No remaining drift. The Terraform code matches the live AWS workgroup exactly. `terraform plan` shows 0 to add, 0 to change, 0 to destroy.

---

**Last Updated:** 2026-06-04  
**Maintained By:** Code generation pipeline (reconciled with live state)
