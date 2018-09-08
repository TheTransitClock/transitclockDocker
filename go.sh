export PGPASSWORD=transitclock

#docker stop transitclock-db
#docker stop transitclock-server-instance

#docker rm transitclock-db
#docker rm transitclock-server-instance

#docker rmi transitclock-server

docker build --no-cache -t transitclock-server \
--build-arg TRANSITCLOCK_PROPERTIES="config/transitclockConfig.xml" \
--build-arg AGENCYID="1" \
--build-arg AGENCYNAME="MBTA" \
--build-arg GTFS_URL="https://cdn.mbta.com/MBTA_GTFS.zip" \
--build-arg GTFSRTVEHICLEPOSITIONS="https://data.texas.gov/download/eiei-9rpf/application%2Foctet-stream" .

docker run --name transitclock-db-instance-2 -p 5433:5432 -e POSTGRES_PASSWORD=$PGPASSWORD -d postgres:9.6.3

docker run --name transitclock-server-instance-2 --rm --link transitclock-db-instance-2:postgres -e PGPASSWORD=$PGPASSWORD transitclock-server check_db_up.sh

docker run --name transitclock-server-instance-2 --rm --link transitclock-db-instance-2:postgres -e PGPASSWORD=$PGPASSWORD transitclock-server create_tables.sh

docker run --name transitclock-server-instance-2 --rm --link transitclock-db-instance-2:postgres -e PGPASSWORD=$PGPASSWORD transitclock-server import_gtfs.sh

docker run --name transitclock-server-instance-2 --rm --link transitclock-db-instance-2:postgres -e PGPASSWORD=$PGPASSWORD transitclock-server create_api_key.sh

docker run --name transitclock-server-instance-2 --rm --link transitclock-db-instance-2:postgres -e PGPASSWORD=$PGPASSWORD transitclock-server create_webagency.sh

#docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD transitclock-server ./import_avl.sh

#docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD transitclock-server ./process_avl.sh

docker run --name transitclock-server-instance-2 --rm --link transitclock-db-instance-2:postgres -e PGPASSWORD=$PGPASSWORD  -p 8081:8080 transitclock-server  start_transitclock.sh
