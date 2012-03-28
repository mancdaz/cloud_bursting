#!/bin/bash

AUTH_URL='http://127.0.0.1:35357'
OS_TENANT_NAME='admin'
OS_USERNAME='admin'
OS_PASSWORD='devstack'
NOVA_URL='http://127.0.0.1:8774'
IMAGE=$(glance index -A devstack |grep -i ami|cut -d' ' -f1)

SERVER_NAME='myserver'

#authenticate and get a token
OS_TOKEN=$(curl -s -d "{\"auth\": {\"tenantName\": \"$OS_TENANT_NAME\", \"passwordCredentials\":{\"username\": \"$OS_USERNAME\", \"password\": \"$OS_PASSWORD\"}}}" -H "Content-type: application/json" $AUTH_URL/v2.0/tokens | python -mjson.tool | grep -A2 token | tail -n1 | cut -d"\"" -f4)
echo "your auth token is: $OS_TOKEN"

#get your tenant ID
OS_TENANT_ID=$(curl -s -d "{\"auth\": {\"tenantName\": \"$OS_TENANT_NAME\", \"passwordCredentials\":{\"username\": \"$OS_USERNAME\", \"password\": \"$OS_PASSWORD\"}}}" -H "Content-type: application/json" $AUTH_URL/v2.0/tokens|python  -mjson.tool|grep -A3 tenant|tail -1|cut -d"\"" -f 4)
echo "your tenant ID is: $OS_TENANT_ID"

#build a server
curl -s -X POST -H "x-auth-project-id: $OS_TENANT_ID" -H "x-auth-token: $OS_TOKEN" -H "Content-type: application/json" -d "{\"server\": {\"min_count\": 1, \"flavorRef\": \"6\", \"name\": \"$SERVER_NAME\", \"imageRef\": \"$IMAGE\", \"max_count\": 1}}" $NOVA_URL/v2/$OS_TENANT_ID/servers | python -mjson.tool
