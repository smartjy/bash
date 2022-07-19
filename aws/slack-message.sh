#!/usr/bin/env bash

YOUR_WEBHOOK_URL=''

curl -X POST -H 'Content-type: application/json' --data \
'{
  "icon_url": "https://a.slack-edge.com/80588/img/api/aws.png",
  "text": ":warning: hello slack message",
}' $YOUR_WEBHOOK_URL