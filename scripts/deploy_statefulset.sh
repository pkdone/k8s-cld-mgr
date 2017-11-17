#!/bin/sh
##
# Script to deploy the MongoDB Agents Service & StatefulSet onto a Kubernetes
# cluster.
##

# Deploy just the StatefulSet & Service
echo
kubectl apply -f ../resources/mongodb-agent-service.yaml
echo
sleep 5

# Print current deployment state (unlikely to be finished yet)
echo
kubectl get all
echo
kubectl get persistentvolumes
echo
printf "Keep running the following command until all 3 pods are shown as running:\n\n\t  kubectl get all\n\n"

