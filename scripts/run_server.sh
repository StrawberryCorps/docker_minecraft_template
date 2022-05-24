#!/bin/sh
set -e

if [ "$1" = 'serve' ]; then

  java -jar $JAVA_ARGS \
    -Xmx$JAVA_HEAP_SIZE -Xms$JAVA_HEAP_SIZE \
    $SERVER_PATH/straw-serv.jar \
    $SPIGOT_ARGS \
    $PAPERSPIGOT_ARGS
fi

exec "$@"
