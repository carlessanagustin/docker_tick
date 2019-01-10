#!/usr/bin/env bash

docker build -t telegraf:agent .

docker run -d --rm \
    --net=tickdocker_influxnet \
    -v $PWD/../etc/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
    telegraf:agent
