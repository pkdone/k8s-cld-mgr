#!/bin/sh
##
# Script to undeploy the MongoDB Agents Service & StatefulSet from the
# Kubernetes cluster.
##

# Undeploy the StatefulSet and Service (keep rest of k8s environment in place)
echo
echo "Undeploying Stateful & Service"
echo
kubectl delete statefulsets mytestapp-mongodb-agent
kubectl delete services mytestapp-mongodb-agent-service
echo
sleep 2

# Show persistent volume claims are still reserved even though StatefulSet has been undeployed
echo
kubectl get persistentvolumes
echo

