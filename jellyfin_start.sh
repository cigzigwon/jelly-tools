#!/bin/bash

docker run -d  -v /srv/jellyfin/config:/config -v /srv/jellyfin/cache:/cache -v /media:/media -p 0.0.0.0:8096:8096 --name jellyfin jellyfin/jellyfin:latest
