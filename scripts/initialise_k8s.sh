#!/bin/sh
##
# Script to prepare a GKE Kubernetes environment and dependency resources 
# ready for deploying a StatefulSet running MongoDB Cloud Manager Automation
# Agents (to subsequently allow the deployment of a MongoDB cluster via the
# Cloud Manager UI or API).
##

# Create new GKE Kubernetes cluster (using host node VM images based on Ubuntu
# rather than ChromiumOS default & also use slightly larger VMs than default)
gcloud container clusters create "gke-mongodb-cld-mgr-demo-cluster" --image-type=UBUNTU --machine-type=n1-standard-2


# Configure host VM using daemonset to disable hugepages
echo "Deploying GKE Daemon Set"
kubectl apply -f ../resources/hostvm-node-configurer-daemonset.yaml


# Register GCE Fast SSD persistent disks and then create the persistent disks 
echo "Creating GCE disks"
kubectl apply -f ../resources/gce-ssd-storageclass.yaml
sleep 5
for i in 1 2 3
do
    # 5 GB disks    
    gcloud compute disks create --size 5GB --type pd-ssd pd-ssd-disk-5g-$i
    # 10 GB disks
    gcloud compute disks create --size 10GB --type pd-ssd pd-ssd-disk-10g-$i
done
sleep 3


# Create persistent volumes using disks created above
echo "Creating GKE Persistent Volumes"
for i in 1 2 3
do
    # Replace text stating volume number + size of disk (set to 5)
    sed -e "s/INST/${i}/g; s/SIZE/5/g" ../resources/xfs-gce-ssd-persistentvolume.yaml > /tmp/xfs-gce-ssd-persistentvolume.yaml
    kubectl apply -f /tmp/xfs-gce-ssd-persistentvolume.yaml
    # Replace text stating volume number + size of disk (set to 10)
    sed -e "s/INST/${i}/g; s/SIZE/10/g" ../resources/xfs-gce-ssd-persistentvolume.yaml > /tmp/xfs-gce-ssd-persistentvolume.yaml
    kubectl apply -f /tmp/xfs-gce-ssd-persistentvolume.yaml
done
rm /tmp/xfs-gce-ssd-persistentvolume.yaml
sleep 3


# Print Summary State
echo
kubectl get persistentvolumes
echo
kubectl get all 
echo

