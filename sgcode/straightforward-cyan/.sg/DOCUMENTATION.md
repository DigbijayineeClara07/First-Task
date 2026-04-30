# 37lxrdhe-private-runner-storage-backend

## Description

S3 bucket for private runner storage backend with server-side encryption and public access blocking.

## Module Overview

| Module | Description |
|--------|-------------|
| `s3_bucket` | Manages the S3 bucket for private runner storage backend |

## Variables Reference

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | AWS region where resources will be managed |
| `bucket` | `string` | Name of the S3 bucket |

## Outputs Reference

| Name | Description |
|------|-------------|
| `bucket_id` | ID of the S3 bucket |
| `bucket_arn` | ARN of the S3 bucket |

## Usage Instructions

### 1. Initialize

```sh
terraform init
```

### 2. Import existing resources

```sh
chmod +x imports.sh
./imports.sh terraform
```

### 3. Plan

```sh
terraform plan -var-file environments/sg.tfvars
```

### 4. Apply

```sh
terraform apply -var-file environments/sg.tfvars
```