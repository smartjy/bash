#!/usr/bin/env bash

YOUR_WEBHOOK_URL='https://hooks.slack.com/services/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'

curl -X POST -H 'Content-type: application/json' --data \
'{
  "icon_url": "https://a.slack-edge.com/80588/img/api/aws.png",
  "text": ":warning: hello slack message",
}' $YOUR_WEBHOOK_URL