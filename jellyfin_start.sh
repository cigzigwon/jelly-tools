#!/bin/bash

docker run -d  -v /srv/jellyfin/config:/config -v /srv/jellyfin/cache:/cache -v /media:/media --net=host --name jellyfin jellyfin/jellyfin:latest
