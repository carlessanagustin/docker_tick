#.DEFAULT_GOAL := enable_k8s

#CERTS_DIR := $(shell docker volume inspect --format '{{ .Mountpoint }}' tick_certs)
#ETC_DIR := $(shell docker volume inspect --format '{{ .Mountpoint }}' tick_etc)
#$(eval CERTS_DIR = $(shell docker volume inspect --format '{{ .Mountpoint }}' tick_certs))
#$(eval ETC_DIR = $(shell docker volume inspect --format '{{ .Mountpoint }}' tick_etc))
CERTS_DIR ?= /var/lib/docker/volumes/tick_certs/_data
ETC_DIR ?= /var/lib/docker/volumes/tick_etc/_data

TEST_VAR := $(shell docker volume inspect --format '{{ .Mountpoint }}' tick_certs)

enable_k8s: enable_security volume_create enable_stack enable_proxy

enable_security: user
	./bin/create_keys.sh

volume_create:
	-docker volume create tick_certs
	-docker volume create tick_etc
	sleep 1
	sudo cp -Rf ./certs/influxdb/* ${CERTS_DIR}
	sudo cp ./etc/influxdb/influxdb.conf ${ETC_DIR}/influxdb.conf
	sudo cp ./etc/kapacitor/kapacitor.conf ${ETC_DIR}/kapacitor.conf
	sudo cp -Rf ./etc/kapacitor/load ${ETC_DIR}

volume_delete:
	-docker volume rm tick_etc
	-docker volume rm tick_certs

full_clean_k8s: disable_stack_k8s full_clean volume_delete

enable_stack_k8s:
	docker-compose -f docker-compose.k8s.yml up -d
	sleep 5

disable_stack_k8s:
	-docker-compose -f docker-compose.k8s.yml down

enable_proxy_k8s:
	@#make user
	docker-compose -f docker-compose.nginx.yml  up -d

test:
	@echo ${TEST_VAR}
	sudo ls -la ${TEST_VAR}
