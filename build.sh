#!/bin/bash
PWD=$(pwd)
SCRIPT_WORKDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BASENAME_LOWER=$(basename $SCRIPT_WORKDIR | tr '[:upper:]' '[:lower:]')

NETNAME=docker

SQLITE_IMAGE='mariort/sqlite-alpine:1.0'
DB_NAME='ip2location.db'

NGINX_IMAGE='nginx:1.13'
WEBSERVER_NAME='geolocate_webserver'

PHP_IMAGE='php:7.1-fpm'
PHP_FPM_NAME='geolocate_php'

COMPOSER_IMAGE='composer:1.5'

function create_network_ifnotexists(){
    
    # -z is if output is empty
    if [ -z "$(docker network ls | grep $1)" ]; then
        docker network create $1
        echo "Network $1 created"
    fi
}

function install(){
    
    create_network_ifnotexists $NETNAME
    composer
    build_sqlite_db
    run_webserver
}

function unzip_sqlite_db(){
    
    docker run --rm -v $SCRIPT_WORKDIR/vendor/mrivera/ip2location/sqlite:/unzip garthk/unzip IP2LOCATION-LITE-DB3.CSV.zip
}

function import_sqlite_db(){
    
    echo "Importing database..."
    docker run -it --rm -e "DB_NAME=$DB_NAME" -v $SCRIPT_WORKDIR/vendor/mrivera/ip2location/sqlite:/sqlite $SQLITE_IMAGE
}

function build_sqlite_db(){
    
    unzip_sqlite_db
    import_sqlite_db
}

function run_nginx(){
    
    docker run -d --name $WEBSERVER_NAME \
    --network=$NETNAME \
    -v $SCRIPT_WORKDIR:/nginx \
    -v $SCRIPT_WORKDIR/docker/nginx/conf/default.conf:/etc/nginx/conf.d/default.conf \
    -p 8080:80 $NGINX_IMAGE
}

function run_php(){
    
    docker run -d --name $PHP_FPM_NAME \
    --network=$NETNAME \
    -v $SCRIPT_WORKDIR:/nginx \
    $PHP_IMAGE
}

function run_webserver(){
    
    # php fpm has to be run before nginx otherwise it will fail to start
    run_php
    run_nginx
}

composer() {

    docker run -it --rm -v $SCRIPT_WORKDIR:/app $COMPOSER_IMAGE bash -c "composer install"
}

function destroy(){
    
    docker stop $WEBSERVER_NAME && docker rm $WEBSERVER_NAME
    docker stop $PHP_FPM_NAME && docker rm $PHP_FPM_NAME
}

$1