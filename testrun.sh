#!/bin/bash

curl -X POST \
  -H 'Content-type: application/json' \
  -H 'auth-token: 8cc14449-5612-42f4-ba58-f2ec7a0f5e10' \
  --data '{"settings":{"httpProxyString": "tunnel.testrigor.com:52600","httpsProxyString": "tunnel.testrigor.com:52600"},"branch": { "name": "my-branch", "commit": "commit-hash"}, "url": "http://ikea.local:8080","forceCancelPreviousTesting":true,"storedValues":{"storedValueName1":"Value"}}' \
  https://api.testrigor.com/api/v1/apps/ois8eMQAQHbTtv7rs/retest

sleep 10

while true
do
  echo " "
  echo "==================================="
  echo " Checking TestRigor retest"
  echo "==================================="
  response=$(curl -i -o - -s -X GET 'https://api.testrigor.com/api/v1/apps/ois8eMQAQHbTtv7rs/status' -H 'auth-token: 8cc14449-5612-42f4-ba58-f2ec7a0f5e10' -H 'Accept: application/json')
  code=$(echo "$response" | grep HTTP |  awk '{print $2}')
  body=$(echo "$response" | grep status)
  echo "Status code: " $code
  echo "Response: " $body
  case $code in
    4*|5*)
      # 400 or 500 errors
      echo "Error calling API"
      exit 1
      ;;
    200)
      # 200: successfully finished
      echo "Test finished successfully"
      exit 0
      ;;
    227|228)
      # 227: New - 228: In progress
      echo "Test is not finished yet"
      ;;
    230)
      # 230: Failed
      echo "Test finished but failed"
      exit 1
      ;;
    *)
      echo "Unknown status"
      exit 1
    esac
  sleep 10
done
