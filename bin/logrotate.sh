#!/usr/bin/env bash
DOCKER_VOLUME=$1
DOCKER_FOLDER=$(docker volume inspect --format '{{ .Mountpoint }}' $DOCKER_VOLUME)


cat << EOF > /etc/logrotate.d/$DOCKER_VOLUME
$DOCKER_FOLDER/*.log {
  rotate 5
  size 100k
  compress
  missingok
  notifempty
}
EOF
