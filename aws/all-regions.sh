#!/usr/bin/env bash

aws ec2 describe-regions \
  --all-regions \
  --query "Regions[].{Name:RegionName}" \
  --output text \
  --no-cli-pager