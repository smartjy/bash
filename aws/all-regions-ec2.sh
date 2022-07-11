#!/usr/bin/env bash

AWS_PROFILE=production

CNT=1

regions=($(aws ec2 describe-regions \
  --all-regions \
  --query "Regions[].{Name:RegionName}" \
  --output text \
  --no-cli-pager))

for region in ${regions[@]}; do
    echo "$CNT -- "$region""
    aws ec2 describe-instances --region $region --no-cli-pager --output text --query "Reservations[*].Instances[*].{Instance:InstanceId,State:Monitoring.State,Name:Tags[?Key=='Name']|[0].Value}" 2>/dev/null
    ((CNT++))
done
