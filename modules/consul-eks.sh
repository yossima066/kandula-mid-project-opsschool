#!/bin/bash
# terraform apply -auto-approve && \
# aws eks --region us-east-1 update-kubeconfig --name  <name of eks>
# kubectl create secret generic consul-gossip-encryption-key --from-literal=key="uDBV4e+LbFW3019YKPxIrg=="
# helm install consul hashicorp/consul -f D:\terraform\kandula-mid-project-opsschool\modules\EKS\values.yaml

# kubectl apply -f  D:\terraform\kandula-mid-project-opsschool\modules\EKS\dnstools.yaml

# CONSULIP=$(kubectl get svc consul-consul-dns | tail -1 |awk '{ print $3 }')

# sed -i -e "s/CONSULIP/${CONSULIP}/g" configmap.yaml

# kubectl apply -f configmap.yaml && \

# sed -i -e "s/${CONSULIP}/CONSULIP/g" configmap.yaml
