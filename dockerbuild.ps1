$PWD=$pwd.Path
$SQLITE_IMAGE='mariort/sqlite-alpine:1.0'
$DB_NAME='ip2location.db'

function build_sqlite_db(){

    docker run -it --rm -e "DB_NAME=$DB_NAME" -v $PWD\sqlite:/sqlite $SQLITE_IMAGE
}

$fn=$args[0]
&"$fn"
