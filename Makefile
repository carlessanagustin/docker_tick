INFLUX_USER ?= admin
INFLUX_PASS ?= admin123
CLIENT_DDBB ?= telegraf
CLIENT_USER ?= telegraf
CLIENT_PASS ?= telegraf123
HTUSER ?= admin
HTPASS ?= test12345678

include ./Makefiles/k8s.mk
include ./Makefiles/gluster.mk
include config

DOCKER_VOLUME = tickdocker_tick_data
INFLUX_CNAME = tickdocker_influxdb_1

all: enable_stack logrotate auth user enable_proxy

local_test: all browser

full_clean: disable_client disable_proxy disable_stack
	@echo " >> [INFO] cleaning environment"
	-docker volume rm ${DOCKER_VOLUME}
	-docker network rm tickdocker_private
	-docker network rm tickdocker_public
	-rm -f etc/nginx/.htpasswd
	-rm -Rf ./certs/
	-sudo rm -Rf ./data
	-sudo rm /etc/logrotate.d/${DOCKER_VOLUME}
	-cp -f ./etc/influxdb/influxdb.conf.bkp ./etc/influxdb/influxdb.conf
	-cp -f ./etc/kapacitor/kapacitor.conf.bkp ./etc/kapacitor/kapacitor.conf
	-cp -f ./etc/telegraf/telegraf.conf.bkp ./etc/telegraf/telegraf.conf
	#-cp -f ./docker-compose.yml.bkp docker-compose.yml

clean: disable_client disable_proxy disable_stack
	@echo " >> [INFO] cleaning environment"
	-docker network rm tickdocker_private
	-docker network rm tickdocker_public

enable_stack:
	@echo " >> [INFO] enabling stack: influx, kapacitor & chronograf"
	./bin/create_keys.sh
	docker-compose up -d

disable_stack:
	@echo " >> [INFO] disabling stack: influx, kapacitor & chronograf"
	-docker-compose down

enable_client:
	@echo " >> [INFO] enabling client: telegraf"
	docker-compose -f docker-compose.client.yml up -d

disable_client:
	@echo " >> [INFO] disabling client: telegraf"
	-docker-compose -f docker-compose.client.yml down

auth:
	@echo " >> [INFO] enable influx authentication"
	cp -f ./etc/influxdb/influxdb.conf ./etc/influxdb/influxdb.conf.bkp
	sed -i "s|#auth-enabled = false|auth-enabled = true|m" ./etc/influxdb/influxdb.conf
	docker-compose restart influxdb
	@echo " >> [INFO] create influx admin user"
	docker exec ${INFLUX_CNAME} \
	    influx -ssl -unsafeSsl -execute \
	    "CREATE USER \"${INFLUX_USER}\" WITH PASSWORD '${INFLUX_PASS}' WITH ALL PRIVILEGES"
	@echo " >> [INFO] create telegraf environment"
	docker exec ${INFLUX_CNAME} \
	    influx -ssl -unsafeSsl \
	    -username ${INFLUX_USER} -password ${INFLUX_PASS} \
	    -execute "CREATE DATABASE ${CLIENT_DDBB}"
	docker exec ${INFLUX_CNAME} \
	    influx -ssl -unsafeSsl \
	    -username ${INFLUX_USER} -password ${INFLUX_PASS} \
	    -execute "CREATE USER \"${CLIENT_USER}\" WITH PASSWORD '${CLIENT_PASS}'"
	docker exec ${INFLUX_CNAME} \
	    influx -ssl -unsafeSsl \
	    -username ${INFLUX_USER} -password ${INFLUX_PASS} \
	    -execute "GRANT ALL ON \"${CLIENT_USER}\" TO \"${CLIENT_DDBB}\""
	@echo " >> [INFO] enable kapacitor authentication"
	cp -f ./etc/kapacitor/kapacitor.conf ./etc/kapacitor/kapacitor.conf.bkp
	sed -i "s|#username = \"admin\"|username = \"${INFLUX_USER}\"|m" ./etc/kapacitor/kapacitor.conf
	sed -i "s|#password = \"admin123\"|password = \"${INFLUX_PASS}\"|m" ./etc/kapacitor/kapacitor.conf
	docker-compose restart kapacitor
	@echo " >> [INFO] enable chronograf authentication"
	cp -f docker-compose.yml docker-compose.yml.bkp
	sed -i "s|#INFLUXDB_USERNAME: admin|INFLUXDB_USERNAME: ${INFLUX_USER}|m" ./docker-compose.yml
	sed -i "s|#INFLUXDB_PASSWORD: admin123|INFLUXDB_PASSWORD: ${INFLUX_PASS}|m" ./docker-compose.yml
	docker-compose restart chronograf
	@echo " >> [INFO] enable telegraf container authentication"
	cp -f  ./etc/telegraf/telegraf.conf ./etc/telegraf/telegraf.conf.bkp
	sed -i "s|#username = \"telegraf\"|username = \"${CLIENT_USER}\"|m" ./etc/telegraf/telegraf.conf
	sed -i "s|#password = \"telegraf123\"|password = \"${CLIENT_PASS}\"|m" ./etc/telegraf/telegraf.conf

user:
	htpasswd -cb ./etc/nginx/.htpasswd ${HTUSER} ${HTPASS}

enable_proxy:
	@echo " >> [INFO] enabling proxy: nginx"
	docker-compose -f docker-compose.nginx.yml up -d

disable_proxy:
	@echo " >> [INFO] disabling proxy: nginx"
	-docker-compose -f docker-compose.nginx.yml down

browser:
	sleep 3
	xdg-open http://127.0.0.1/chronograf

logrotate:
	@echo " >> [INFO] setting up logrotate"
	sudo ./bin/logrotate.sh ${DOCKER_VOLUME}
