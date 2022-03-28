#!/bin/bash

aws eks --region us-east-1 update-kubeconfig --name  yossi-eks
sleep 3
kubectl create secret generic consul-gossip-encryption-key --from-literal=key="uDBV4e+LbFW3019YKPxIrg=="
sleep 3
helm install consul hashicorp/consul -f values.yaml

sleep 3
kubectl apply -f  filebeat.yaml

#kubectl apply -f  dnstools.yaml
sleep 3
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
sleep 10
helm repo update
sleep 5
helm install prometehusnew prometheus-community/kube-prometheus-stack

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability.yaml
sleep 3
kubectl apply -f hpa.yaml

CONSULIP=$(kubectl get svc consul-consul-dns | tail -1 |awk '{ print $3 }')

sed -i -e "s/CONSULIP/${CONSULIP}/g" configmap.yaml

kubectl apply -f configmap.yaml && \

sed -i -e "s/${CONSULIP}/CONSULIP/g" configmap.yaml


