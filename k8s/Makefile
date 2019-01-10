-include private.mk

delete:
	-kubectl delete -f chronograf-ingress.yaml
	-kubectl delete -f chronograf-svc.yaml
	-kubectl delete -f telegraf-DaemonSet.yaml
	-kubectl delete -f influxdb-svc.yaml
	-kubectl delete -f influxdb-deploy.yaml
	-kubectl delete -f kapacitor-svc.yaml
	-kubectl delete -f kapacitor-deploy.yaml
	-kubectl delete -f chronograf-deploy.yaml
	-kubectl delete -f gluster-pvc.yaml
	-kubectl delete -f gluster-pv.yaml
	-kubectl delete -f gluster-ep.yaml
	-kubectl delete -f tick-ns.yaml

create:
	kubectl create -f tick-ns.yaml
	kubectl create -f gluster-ep.yaml
	-kubectl create -f gluster-pv.yaml
	kubectl create -f gluster-pvc.yaml
	kubectl create -f influxdb-svc-cluster.yaml
	kubectl create -f influxdb-svc-node.yaml
	kubectl create -f chronograf-svc.yaml
	kubectl create -f kapacitor-svc.yaml
	kubectl create -f kapacitor-deploy.yaml
	kubectl create -f chronograf-deploy.yaml
	kubectl create -f influxdb-deploy.yaml
	kubectl create -f telegraf-DaemonSet.yaml
	kubectl create -f chronograf-ingress.yaml

get:
	kubectl -n tick get pods,deploy,rs,ds,ep,pv,pvc,ingress,svc,configmaps -o wide
