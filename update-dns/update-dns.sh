#!/usr/bin/zsh

RCTIPLUSCOM="398c47e3fcbcbc9f87e2392a90e6df2c"
DOMAIN_NAME="interactive-catalogue.rctiplus.com"
EMAIL="fta.rctiplus@gmail.com"
TOKEN="ROnLXZFSuwty-RJwyHaGeCRW34_9qxWk55ekVh8U"

GET_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$RCTIPLUSCOM/dns_records?name=$DOMAIN_NAME" --header "X-Auth-Email: $EMAIL" --header "Authorization: Bearer $TOKEN" | jq ".result[0].id")

curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/$RCTIPLUSCOM/dns_records/$GET_ID" \
    -H "X-Auth-Email: $EMAIL" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: text/plain" \
    -d "{
  "content": "110.239.68.47",
  "type": "A",
  "comment": "Domain verification record",
  "tags": [
    "owner:dns-team"
  ],
  "ttl": 1
}"
