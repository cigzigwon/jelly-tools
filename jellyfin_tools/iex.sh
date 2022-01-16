#!/bin/bash

docker run --rm -it -v $(pwd):/usr/src/jellyfin_tools -v /media/chris:/root/media/ -v mix:/root/.mix/ -w /usr/src/jellyfin_tools elixir:1.13-alpine iex -S mix