#!/bin/bash

# if no arg supplied, delete 1 server
# if no arg specified, assume build
FLAG=${1:-'-b'}
NUM=${2:-1}
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

function usage() {
    cat >&2 <<EOF
usage: $(basename $0)   [-b|--build [NUM]]      * build NUM servers
                        [-d|--delete [NUM]]     * delete NUM servers
EOF

}
                        

function build_servers() {
    NUM_SERVERS=$1
    for i in $(seq ${NUM_SERVERS}) ; do
    #build a server
    ID=$(curl -s -X POST -H "x-auth-project-id: $OS_TENANT_ID" -H "x-auth-token: $OS_TOKEN" -H "Content-type: application/json" -d "{\"server\": {\"min_count\": 1, \"flavorRef\": \"6\", \"name\": \"$SERVER_NAME-${i}\", \"imageRef\": \"$IMAGE\", \"max_count\": 1}}" $NOVA_URL/v2/$OS_TENANT_ID/servers | python -mjson.tool | grep '"id"'| cut -d"\"" -f4)
    echo "building server id: $ID"
    done
}

function delete_servers() {
    NUM_SERVERS=$1
    SERVER_LIST=$(curl -s -H "x-auth-project-id: $OS_TENANT_ID" -H "x-auth-token: $OS_TOKEN" -H "Content-type: application/json" $NOVA_URL/v2/$OS_TENANT_ID/servers | python -mjson.tool|grep -i id|cut -d"\"" -f4)
    # delete specified number of servers
    for i in $(echo "$SERVER_LIST" | tail -n $NUM_SERVERS) ; do
        echo "deleting server id: $i"
        curl -s -X DELETE  -H "x-auth-project-id: $OS_TENANT_ID" -H "x-auth-token: $OS_TOKEN" -H "Content-type: application/json" $NOVA_URL/v2/$OS_TENANT_ID/servers/$i
    done
}


# perform actions based on whether we were called with -b or -d

case "$FLAG" in

    "-b"|"--build")
        build_servers $NUM;;

    "-d"|"--delete")
        delete_servers $NUM;;
    *)
        usage;;
esac
