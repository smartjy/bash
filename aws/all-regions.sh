#!/usr/bin/env bash

AWS_PROFILE=suite-prod

CNT=1

regions=($(aws ec2 describe-regions \
  --all-regions \
  --query "Regions[].{Name:RegionName}" \
  --output text \
  --no-cli-pager))

for region in ${regions[@]}; do
    echo "$CNT -- "$region""
    #aws rds describe-db-instances --region $region --no-cli-pager --output text --query "DBInstances[*].DBInstanceIdentifier" 2>/dev/null
    aws --profile $AWS_PROFILE  ec2 describe-addresses --output text --region $region --no-cli-pager 2>/dev/null
    ((CNT++))
done
