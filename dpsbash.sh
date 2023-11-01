#!/bin/bash

#boring settings
PS_NAME="some-prestashop"
PS_IMAGE="prestashop/prestashop:latest"

MYSQL_NAME="some-mysql"
MYSQL_PWD="admin"
MYSQL_IMAGE="mysql:5.7"

PS_NETWORK="prestashop-net"

PSDATA_DIR="psdata"
DBDATA_DIR="dbdata"

display_commands() {
    echo "Available commands for containers in directory: $PS_NAME, $MYSQL_NAME, $NETWORK_NAME"
    echo "  start     - Start the containers"
    echo "  stop      - Stop the containers"
    echo "  create    - Create a new shop"
    echo "  clear     - Clear all data"
    echo "  exit      - Exit the script"
}

check_folders() {
# Sjekker om det finnes mapper, psdata og dbdata
if [ ! -d "$PSDATA_DIR" ]; then
    echo "$PSDATA_DIR directory not found. Creating..."
    mkdir $PSDATA_DIR
fi
if [ ! -d "$DBDATA_DIR" ]; then
    echo "$DBDATA_DIR directory not found. Creating..."
    mkdir $DBDATA_DIR
fi
echo "ok"
}

create_new_shop() {
check_folders

#lag network container
docker network create prestashop-net

#lag mysql container
sudo docker run -ti \
    --name $MYSQL_NAME \
    --network $PS_NETWORK \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_PWD \
    -p 3307:3306 \
    -v $(pwd)/$DBDATA_DIR:/var/lib/mysql \
    -d $MYSQL_IMAGE

#lag prestashop container
sudo docker run -ti \
  --name $PS_NAME \
  --network $PS_NETWORK \
  -e DB_SERVER=$MYSQL_NAME \
  -p 8080:80 \
  -v $(pwd)/$PSDATA_DIR:/var/www/html \
  -d $PS_IMAGE
    exit 0 # Exit the script after clearing
    
}

clearAll() {
    echo "Clearing all data..."
        stop_container
        sudo docker rm $PS_NETWORK
        sudo docker rm $MYSQL_NAME
        sudo docker rm $PS_NAME
        sudo rm -rf ./psdata && sudo rm -rf ./dbdata
        echo "Clearing ok";
        
}
stop_container() {
    echo "Stop container $PS_NAME, $MYSQL_NAME"
    sudo docker stop $PS_NAME
    sudo docker stop $MYSQL_NAME
    echo "ok"
}
start_container() {
    echo "Starting container $PS_NAME, $MYSQL_NAME"
    sudo docker start $MYSQL_NAME
    sudo docker start $PS_NAME
}
# Main execution

if [ -z "$1" ]; then
    display_commands
    exit 0
fi

case "$1" in
    start)
        echo "Starting!"
        start_container
        ;;
    stop)
        echo "Stopping!"
        stop_container
        ;;
    create)
        echo "Creating"
        create_new_shop
        ;;
    clear)
        echo "Sletter!"
        clearAll
        ;;  
    --help)
        display_commands
        exit 0
        ;;  
    exit)
        echo "Hade..."
        exit 0
        ;;
    *)
        echo "Cannot recognize '$1', try --help"
        ;;
esac
##!/bin/bash
#git clone https://github.com/PrestaShop/php-ps-info.git
#mv php-ps-info ./psdata/php-ps-info 
