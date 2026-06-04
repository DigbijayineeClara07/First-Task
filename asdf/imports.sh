#!/bin/sh
set -e

"$1" import -var-file environments/sg.tfvars 'module.athena_workgroup.aws_athena_workgroup.this' 'primary'