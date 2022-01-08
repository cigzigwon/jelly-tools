#!/bin/bash

docker create \
  --name=swag \
  --cap-add=NET_ADMIN \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/Detroit \
  -e URL=pyroclasti.cloud \
  -e SUBDOMAINS=jellyfin, \
  -e VALIDATION=http \
  -e EMAIL=csobeck@pyroclasti.cloud \
  -e DHLEVEL=2048 \
  -e ONLY_SUBDOMAINS=true \
  -e STAGING=false \
  -p 443:443 \
  -p 80:80 \
  -v /home/chris/.config/swag:/config \
  --restart unless-stopped \
  linuxserver/swag

# use container
# docker start swag
