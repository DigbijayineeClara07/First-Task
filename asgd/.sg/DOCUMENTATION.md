# Athena Workgroup Infrastructure — OpenTofu/Terraform Documentation

**Date generated:** June 4, 2026  
**Status:** Reconciled — plan shows 0 to add, 0 to change, 0 to destroy  
**Region:** `ap-southeast-1`  
**AWS Account:** `714114208215`

---

## 1. Overview

This OpenTofu/Terraform configuration manages a single **AWS Athena workgroup** named `primary` in the `ap-southeast-1` region. 

### What was done:

- **Discovery phase:** The workgroup was identified and its current configuration was exported.
- **Code generation:** Terraform code was auto-generated to match the discovered resource.
- **Import phase:** The workgroup was imported into OpenTofu state via `imports.sh`, mapping the cloud resource to the Terraform address `module.athena_workgroup["primary"].aws_athena_workgroup.this`.
- **Reconciliation:** The configuration was adjusted until `plan` showed zero changes, confirming that the code and state match the cloud resource exactly.

The result is a minimal, deterministic infrastructure-as-code representation of the Athena workgroup, suitable for version control, environment promotion, and policy-driven changes.

---

## 2. Resources

| Terraform Address | Provider | Type | Real-World Name/ID | Purpose |
|---|---|---|---|---|
| `module.athena_workgroup["primary"].aws_athena_workgroup.this` | `hashicorp/aws` | `aws_athena_workgroup` | `primary` | Athena workgroup with CloudWatch metrics enabled, non-enforced workgroup config, requester-pays disabled, AUTO engine version |

**Summary:**
- **1 managed resource**
- **0 data sources**
- **0 external modules**

---

## 3. Module Structure

### Local Modules

#### `modules/athena_workgroup/`

**Purpose:** Encapsulates the creation and configuration of an AWS Athena workgroup.

**Files:**
- `main.tf` — Declares the `aws_athena_workgroup` resource with all configurable attributes.
- `variables.tf` — Defines 7 input variables (name, description, enforce_workgroup_configuration, publish_cloudwatch_metrics_enabled, requester_pays_enabled, selected_engine_version, tags).
- `outputs.tf` — Exports `workgroup_name` and `workgroup_arn`.

**Resource creation:**
- Creates exactly **1** `aws_athena_workgroup` resource per module instantiation.
- Module is called from root via `for_each` over the `var.athena_workgroups` map, allowing multiple workgroups to be managed by repeating the module block with different map keys.

**Call site (root `main.tf`):**
```hcl
module "athena_workgroup" {
  source   = "./modules/athena_workgroup"
  for_each = var.athena_workgroups
  
  name                              = each.value.name
  description                       = each.value.description
  enforce_workgroup_configuration   = each.value.enforce_workgroup_configuration
  publish_cloudwatch_metrics_enabled = each.value.publish_cloudwatch_metrics_enabled
  requester_pays_enabled            = each.value.requester_pays_enabled
  selected_engine_version           = each.value.selected_engine_version
  tags                              = each.value.tags
}
```

**No external modules** — all infrastructure is defined locally.

---

## 4. How Import Works

### One-time import (already completed)

The `imports.sh` script executed a single import command to bring the cloud workgroup into Terraform state:

```bash
#!/bin/sh
set -e
"$1" import -var-file environments/sg.tfvars 'module.athena_workgroup["primary"].aws_athena_workgroup.this' 'primary'
```

**Breakdown:**
- `"$1"` — the OpenTofu/Terraform binary path (passed as a shell argument)
- `-var-file environments/sg.tfvars` — loads the environment variables (the `athena_workgroups` map)
- `module.athena_workgroup["primary"].aws_athena_workgroup.this` — Terraform address (module instance `primary`, resource `aws_athena_workgroup.this`)
- `'primary'` — the cloud resource ID (the workgroup name)

### Intended use:

**Do not run `imports.sh` again** unless state is lost or the resource is manually deleted from state. Once imported, `plan` and `apply` manage the resource's ongoing state and configuration.

### Re-importing a single resource (if state is lost):

To re-import the workgroup and restore state without running `imports.sh`:

```bash
opentofu import -var-file=environments/sg.tfvars 'module.athena_workgroup["primary"].aws_athena_workgroup.this' 'primary'
```

Or with Terraform (if using Terraform instead of OpenTofu):

```bash
terraform import -var-file=environments/sg.tfvars 'module.athena_workgroup["primary"].aws_athena_workgroup.this' 'primary'
```

The import argument is the workgroup's **name** (`primary`), not its ARN.

---

## 5. How to Use the Code

### Prerequisites

- OpenTofu or Terraform CLI installed (reference: `/tmp/tmp.PFNjpB/tofu` is the OpenTofu binary used during discovery).
- AWS credentials configured with permissions to read/write Athena workgroups in `ap-southeast-1`.
- Working directory: `/mnt/sg_workspace/user/sgcode`

### Initialize the working directory

Run this once to download providers and modules:

```bash
cd /mnt/sg_workspace/user/sgcode
opentofu init
```

Or with Terraform:

```bash
terraform init
```

### Plan changes

To see what changes would be applied:

```bash
opentofu plan -var-file=environments/sg.tfvars
```

Expected output: **0 to add, 0 to change, 0 to destroy** (the state is in sync with the code and the cloud resource).

### Apply changes

To apply the configuration (idempotent if plan shows no changes):

```bash
opentofu apply -var-file=environments/sg.tfvars
```

### Target a different environment

To manage a different set of workgroups or change workgroup settings:

1. **Copy** the environment file:
   ```bash
   cp environments/sg.tfvars environments/prod.tfvars
   ```

2. **Edit** the new file to change workgroup names, descriptions, or other properties:
   ```bash
   # Example: modify prod.tfvars
   athena_workgroups = {
     primary = {
       name                               = "primary"
       description                        = "Production Athena workgroup"
       enforce_workgroup_configuration    = true  # Changed from false
       publish_cloudwatch_metrics_enabled = true
       requester_pays_enabled             = false
       selected_engine_version            = "AUTO"
       tags                               = { Environment = "prod" }
     }
     secondary = {
       name                               = "secondary"
       description                        = "Secondary production workgroup"
       enforce_workgroup_configuration    = false
       publish_cloudwatch_metrics_enabled = true
       requester_pays_enabled             = false
       selected_engine_version            = "AUTO"
       tags                               = { Environment = "prod" }
     }
   }
   ```

3. **Plan** with the new file (no `.tf` edits required):
   ```bash
   opentofu plan -var-file=environments/prod.tfvars
   ```

4. **Apply** with the new file:
   ```bash
   opentofu apply -var-file=environments/prod.tfvars
   ```

**Key principle:** All environment-specific values live in `.tfvars` files. The `.tf` code is environment-agnostic and does not need modification.

---

## 6. Variables

### Root-level variables (`variables.tf`)

#### `athena_workgroups`

| Property | Type | Default | Required | Description |
|---|---|---|---|---|
| `athena_workgroups` | `map(object({...}))` | `{}` | No | Map of Athena workgroup configurations, keyed by logical name (e.g., `"primary"`). |

**Object schema** (each workgroup in the map):

| Field | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Name of the Athena workgroup (required). |
| `description` | `string` | `""` | Optional description of the workgroup. |
| `enforce_workgroup_configuration` | `bool` | `true` | Whether to enforce workgroup configuration on queries. Set to `false` to allow client-side overrides. |
| `publish_cloudwatch_metrics_enabled` | `bool` | `true` | Whether to publish query metrics to CloudWatch. |
| `requester_pays_enabled` | `bool` | `false` | Whether S3 requester-pays buckets are allowed. |
| `selected_engine_version` | `string` | `"AUTO"` | Athena SQL engine version (`"AUTO"`, `"ENGINE_VERSION_3"`, `"PROVISIONED_DPU_ENGINE_VERSION"`). |
| `tags` | `map(string)` | `{}` | AWS tags to apply to the workgroup. |

**Example (from `environments/sg.tfvars`):**

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

---

## 7. Infrastructure Graph

```
Root Module
└── module.athena_workgroup["primary"]
    └── aws_athena_workgroup.this (name: "primary")
        ├── CloudWatch Metrics Publishing: enabled
        ├── Workgroup Configuration Enforcement: disabled
        ├── Requester Pays: disabled
        ├── Engine Version: AUTO (Athena engine version 3)
        └── Tags: (none)

Output
└── root output "athena_workgroup_ids"
    └── Exports: { "primary" = "primary" }
```

**Dependencies:**
- No cross-module dependencies (single, independent workgroup).
- No external data sources (all configuration is explicit).
- No VPC, IAM, or S3 dependencies managed in this code (they are external, assumed to exist if referenced by client queries).

---

## 8. Notable Decisions & Caveats

(Sourced from `.sg/handoff.md` — decisions made during code generation and reconciliation)

### Configuration & Attributes

- **`configuration` block always emitted:** The module always includes the `configuration` block, even if some sub-attributes are empty. This ensures explicit, idempotent behavior.

- **`engine_version` sub-block with `"AUTO"`:** The `selected_engine_version` is set to `"AUTO"` as discovered. This allows AWS to automatically select the latest compatible Athena SQL engine (Athena engine version 3 in this case). To pin a specific version, change this value to `"ENGINE_VERSION_3"` or `"PROVISIONED_DPU_ENGINE_VERSION"`.

- **`enforce_workgroup_configuration = false` is non-default:** The default for this setting is `true` (enforce), but the discovered workgroup has it set to `false` (allow clients to override). This is explicitly configured in `environments/sg.tfvars` to match the cloud resource; changing it in the tfvars file will modify the workgroup behavior on next `apply`.

- **Empty description and tags:** Both `description` and `tags` are empty (`""` and `{}`, respectively) as discovered. These can be populated via the tfvars file without code changes.

### Omitted Computed Attributes

The following AWS-managed, read-only attributes are **intentionally omitted** from the configuration:

- `state` — The workgroup state (ENABLED, DISABLED). Managed by AWS; read via output if needed.
- `arn` — The Amazon Resource Name. Computed and exposed via module output `workgroup_arn`.
- `creation_time` — The workgroup creation timestamp.
- `effective_engine_version` — The actual engine version in use (computed from `selected_engine_version`).

These are not in the `.tf` code to avoid spurious drift or attempted overrides.

### Lifecycle Management

- **No `lifecycle { ignore_changes }` blocks:** The `aws_athena_workgroup` resource has no ephemeral or write-only attributes requiring ignore-list management. All attributes are consistently read and written.

### Plan Status

- **Zero changes:** The final reconciliation achieved a clean plan (0 to add, 0 to change, 0 to destroy), confirming the configuration fully represents the cloud state.

### Scalability

- **Future workgroups:** To add a new Athena workgroup (e.g., `"secondary"`, `"dev"`), simply add a new entry to the `athena_workgroups` map in the tfvars file. The module's `for_each` will automatically create the new resource. No `.tf` code changes needed.

---

## Appendix: File Structure

```
/mnt/sg_workspace/user/sgcode/
├── .sg/
│   ├── handoff.md                  (import & reconciliation notes)
│   └── DOCUMENTATION.md            (this file)
├── .terraform/                      (provider cache; auto-generated)
├── .terraform.lock.hcl              (provider version lock; commit to VCS)
├── environments/
│   └── sg.tfvars                   (environment variables for the primary workgroup)
├── modules/
│   └── athena_workgroup/
│       ├── main.tf                 (resource definition)
│       ├── variables.tf            (input variables)
│       └── outputs.tf              (output values)
├── main.tf                         (root module, calls athena_workgroup)
├── variables.tf                    (root-level variable declarations)
├── outputs.tf                      (root-level outputs)
├── providers.tf                    (AWS provider configuration)
├── versions.tf                     (required provider versions)
├── imports.sh                      (one-time import script; already executed)
└── terraform.tfstate               (current Terraform state; do not edit)
```

---

**End of Documentation**
