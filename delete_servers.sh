#!/bin/bash

# if no arg supplied, delete 1 server
DEL_NUM=${1:-1}

AUTH_URL='http://127.0.0.1:35357'
OS_TENANT_NAME='admin'
OS_USERNAME='admin'
OS_PASSWORD='devstack'
NOVA_URL='http://127.0.0.1:8774'
IMAGE=$(glance index -A devstack |grep -i ami|cut -d' ' -f1)



#authenticate and get a token
OS_TOKEN=$(curl -s -d "{\"auth\": {\"tenantName\": \"$OS_TENANT_NAME\", \"passwordCredentials\":{\"username\": \"$OS_USERNAME\", \"password\": \"$OS_PASSWORD\"}}}" -H "Content-type: application/json" $AUTH_URL/v2.0/tokens | python -mjson.tool | grep -A2 token | tail -n1 | cut -d"\"" -f4)

#get your tenant ID
OS_TENANT_ID=$(curl -s -d "{\"auth\": {\"tenantName\": \"$OS_TENANT_NAME\", \"passwordCredentials\":{\"username\": \"$OS_USERNAME\", \"password\": \"$OS_PASSWORD\"}}}" -H "Content-type: application/json" $AUTH_URL/v2.0/tokens|python  -mjson.tool|grep -A3 tenant|tail -1|cut -d"\"" -f 4)

# list servers

SERVER_LIST=$(curl -s -H "x-auth-project-id: $OS_TENANT_ID" -H "x-auth-token: $OS_TOKEN" -H "Content-type: application/json" $NOVA_URL/v2/$OS_TENANT_ID/servers | python -mjson.tool|grep -i id|cut -d"\"" -f4)

# delete specified number of servers

for i in $(echo "$SERVER_LIST" | tail -n $DEL_NUM) ; do
    echo "deleting server id: $i"
    curl -s -X DELETE  -H "x-auth-project-id: $OS_TENANT_ID" -H "x-auth-token: $OS_TOKEN" -H "Content-type: application/json" $NOVA_URL/v2/$OS_TENANT_ID/servers/$i
done
