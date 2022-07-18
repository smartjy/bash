#!/usr/bin/env bash

YOUR_WEBHOOK_URL=''

curl -X POST -H 'Content-type: application/json' --data \
'{
  "text":"Hello, World!"
  "image_url":"https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg"
}' $YOUR_WEBHOOK_URL