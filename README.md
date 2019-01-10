# TICK Stack

Run the complete TICK stack using this [docker-compose](https://docs.docker.com/compose/) file.
By using docker-compose all four official TICK stack images are started and linked together.
To know more about the individual components see [this](https://influxdata.com/).

This stack is composed of:

* Server: Influxdb + Kapacitor + Chronograf.
* Client: Telegraf.
* HTTP Proxy: Nginx (Includes SSL encryption & user/password access).

## Quick usage

### Start server

1. [OPTIONAL] Place own SSL keys (https.key & https.cert) in `certs/influxdb` & `certs/nginx`
2. Change `config` file as needed.
3. Start server (this will create keys automatically if not created): `make all`
4. Go to [http://127.0.0.1/chronograf](http://127.0.0.1/chronograf).
5. Use created username & password to access Chronograf UI (default user/pass: admin/test12345678)
6. Enable Configuration > Default > Unsafe SSL > Enable
7. Enable Configuration > Default > Username > (default: admin)
8. Enable Configuration > Default > Password > (default: admin123)
9. Enable Configuration > Default > Save Changes

#### tl;dr

```shell
make local_test
```

* Use created username & password to access Chronograf UI (default user/pass: admin/test12345678)
* Enable Configuration > Default > Unsafe SSL > Enable
* Enable Configuration > Default > Username > (default: admin)
* Enable Configuration > Default > Password > (default: admin123)
* Enable Configuration > Default > Save Changes

### Start client

* Option 1: Launch a Telegraf client on Docker: `make enable_client`
* Option 2: Install & launch Telegraf client in Ubuntu host: `./build/telegraf/install_telegraf_Ubuntu.sh`

## Setup

Container configuration files are located at `./etc/`.

### Client (Telegraf)

* Enable & setup plugins as you need: https://github.com/influxdata/telegraf/tree/master/plugins
* Option 1 - As container: `./etc/telegraf/telegraf.conf`
* Option 2 - Installed in host: `/etc/telegraf/*`
* OR follow official instructions: https://docs.influxdata.com/telegraf/v1.7/

### Notifications (Kapacitor)

* Kapacitor alerts log: `tail -f /var/lib/docker/volumes/tickdocker_tick_data/_data/kapacitor_alerts.log`
* Change Kapacitor TICKscripts URL destination: `find ./etc/kapacitor/load/tasks/*.tick | xargs sed -i "s|www.example.com|127.0.0.1|g"`
* Location:

```
.
├── kapacitor
    ├── kapacitor.conf
    └── load
        └── tasks
            └──  * (TICKscripts)
```

* OR follow official instructions: https://docs.influxdata.com/kapacitor/v1.5/

## Build-in commands

### Server

* `make enable_stack`: Generate SSL self-signed certificate if needed & start server (Influxdb + Kapacitor + Chronograf).
* `make disable_stack`: Stop server.

### Client

* `make enable_client`: Add client (Telegraf).
* `make disable_client`: Delete client.

### Proxy

* `make user`: Add user & password authentication to nginx proxy.
* `make user HTUSER=<custom user> HTPASS=<custom password>`: Add user & password authentication to nginx proxy.
* `make enable_proxy`: Add NGINX proxy for Chronograf.
* `make disable_proxy`: Deletes NGINX proxy. Then remove `chronograf > command` line from `docker-compose.yml` and restart Chronograf container.

### General

* `make clean`: Stops ALL elements & deletes network configurations.
* `make full_clean`: BEWARE Only for development purposes! Stops ALL elements & deletes all data & configurations.

## Help files

* `bin/create_keys.sh`: Generate SSL self-signed certificate in `certs/influxdb` & `certs/nginx`
* `bin/task_status.sh`: Enable/disable all Kapacitor tasks. Usage: `docker exec -it tickdocker_kapacitor_1 task_status enable|disable`
* `bin/logrotate.sh <filename>`: Setup logrotate for logs in Kapacitor Docker volume.

## Kubernetes resources
(TODO: update)

* Files to review:

```shell
./k8s/chronograf-deploy.yaml
./k8s/chronograf-ingress.yaml
./k8s/gluster-ep.yaml
```

* Commands to run:

```shell
cd k8s
make create
make get
```

---

Stack created by Carles San Agustin

* http://www.carlessanagustin.com
* https://twitter.com/carlesanagustin
