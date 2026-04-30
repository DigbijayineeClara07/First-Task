#!/bin/sh
set -e

"$1" import -var-file environments/sg.tfvars 'module.s3_bucket.aws_s3_bucket.this' '37lxrdhe-private-runner-storage-backend'