# must be run as root
GSERVER ?= gserver
GBRICK ?= /data/k8s/TICK
GVOLUME ?= tick_shared
GLOGS ?= /var/log/glusterfs/bricks

TEST_FOLDER = /tmp/k8s

requirements:
	bash ./bin/create_keys.sh


gluster_ready: gluster_create cp_files

gluster_create:
	mkdir -p ${GBRICK}
	gluster volume create ${GVOLUME} ${GSERVER}:${GBRICK} force
	gluster volume start ${GVOLUME}

cp_files:
	mkdir -p ${GBRICK}/etc
	cp -Rf ./etc/kapacitor ${GBRICK}/etc
	cp -Rf ./etc/influxdb ${GBRICK}/etc
	mkdir -p ${GBRICK}/etc/ssl
	cp -Rf ./certs/influxdb ${GBRICK}/etc/ssl

gluster_delete:
	gluster volume stop ${GVOLUME} force
	gluster volume delete ${GVOLUME}

gluster_quota:
	@# EXPERIMENTAL
	gluster volume quota ${GVOLUME} enable
	gluster volume quota ${GVOLUME} limit-usage / 5GB 80%
	gluster volume quota ${GVOLUME} limit-usage /logs 250MB 90%
	gluster volume quota ${GVOLUME} list
	tail -f ${GLOGS}/data-k8s-TICK.log

# test
gluster_mount:
	mkdir -p ${TEST_FOLDER}
	mount -t glusterfs ${GSERVER}:/${GBRICK} ${TEST_FOLDER}
	ls ${TEST_FOLDER}

gluster_umount:
	umount ${TEST_FOLDER}
