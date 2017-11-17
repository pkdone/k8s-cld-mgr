#!/bin/sh
##
# Script to remove/undeploy all resources and Kubernetes cluser from GKE & GCE.
##

# Delete host vm configurer daemonset
kubectl delete daemonset hostvm-configurer
sleep 3

# Delete persistent volume claims
kubectl delete persistentvolumeclaims -l role=mongo
sleep 3

# Delete persistent volumes
for i in 1 2 3
do
    kubectl delete persistentvolumes data-volume-5g-$i
    kubectl delete persistentvolumes data-volume-10g-$i
done
sleep 20

# Delete GCE disks
for i in 1 2 3
do
    gcloud -q compute disks delete pd-ssd-disk-5g-$i
    gcloud -q compute disks delete pd-ssd-disk-10g-$i
done

# Delete whole Kubernetes cluster (including its VM instances)
gcloud -q container clusters delete "gke-mongodb-cld-mgr-demo-cluster"

