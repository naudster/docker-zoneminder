#!/bin/bash

docker run -d --name="Zoneminder" \
--privileged="true" \
-p 8080:80/tcp \
-e TZ="Australia/Melbourne" \
-e SHMEM="75%" \
-v /mnt/nas/zoneminder/data:/var/cache/zoneminder:rw \
-v /mnt/nas/zoneminder/mysql:/config/mysql:rw \
docker-zoneminder

