export PGPASSWORD=transitclock
export SERVERNAME=transitclock-server-instance-test
export DATABASENAME=transitclock-db-test
export TRANSITCLOCK_PORT=8086
export DATABASE_PORT=5436
export QUEUENAME=transitclock-queue-test

docker stop $DATABASENAME
docker stop $SERVERNAME
docker stop $QUEUENAME

docker rm $DATABASENAME
docker rm $SERVERNAME
docker rm $QUEUENAME

docker rmi transitclock-server

docker build --no-cache -t transitclock-server \
--build-arg TRANSITCLOCK_PROPERTIES="config/transitclock.properties" \
--build-arg AGENCYID="1" \
--build-arg AGENCYNAME="LAMETRO" \
--build-arg GTFS_URL="https://transitfeeds.com/p/la-metro/184/latest/download" \
--build-arg GTFSRTVEHICLEPOSITIONS='https://www.ztm.poznanepl/pl/dla-deweloperow/getGtfsRtFile/?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ0ZXN0Mi56dG0ucG96bmFuLnBsIiwiY29kZSI6MSwibG9naW4iOiJtaFRvcm8iLCJ0aW1lc3RhbXAiOjE1MTM5NDQ4MTJ9.ND6_VN06FZxRfgVylJghAoKp4zZv6_yZVBu_1-yahlo&file=vehicle_positions.pb' .

docker run --name $DATABASENAME -p $DATABASE_PORT:5432 -e POSTGRES_PASSWORD=$PGPASSWORD -d postgres:9.6.3

docker run --name $QUEUENAME -d hornetq-server

docker run --name $SERVERNAME --rm --link $DATABASENAME:postgres --link $QUEUENAME:hornetq -e PGPASSWORD=$PGPASSWORD -v ~/logs:/usr/local/transitclock/logs/ transitclock-server check_db_up.sh

docker run --name $SERVERNAME --rm --link $DATABASENAME:postgres --link $QUEUENAME:hornetq -e PGPASSWORD=$PGPASSWORD -v ~/logs:/usr/local/transitclock/logs/ transitclock-server create_tables.sh

docker run --name $SERVERNAME --rm --link $DATABASENAME:postgres --link $QUEUENAME:hornetq -e PGPASSWORD=$PGPASSWORD -v ~/logs:/usr/local/transitclock/logs/ transitclock-server import_gtfs.sh

docker run --name $SERVERNAME --rm --link $DATABASENAME:postgres --link $QUEUENAME:hornetq -e PGPASSWORD=$PGPASSWORD -v ~/logs:/usr/local/transitclock/logs/ transitclock-server create_api_key.sh

docker run --name $SERVERNAME --rm --link $DATABASENAME:postgres --link $QUEUENAME:hornetq -e PGPASSWORD=$PGPASSWORD -v ~/logs:/usr/local/transitclock/logs/ transitclock-server create_webagency.sh

docker run --name $SERVERNAME --rm --link $DATABASENAME:postgres --link $QUEUENAME:hornetq -e PGPASSWORD=$PGPASSWORD  -v ~/logs:/usr/local/transitclock/logs/$SERVERNAME/ -v ~/ehcache:/usr/local/transitclock/cache/SERVERNAME/ -p $TRANSITCLOCK_PORT:8080 transitclock-server  start_transitclock.sh
