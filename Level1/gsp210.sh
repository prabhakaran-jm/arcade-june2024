#!/bin/bash

gcloud compute networks create mynetwork --subnet-mode=auto

gcloud compute instances create mynet-us-vm \
--zone=$ZONE1 \
--machine-type=e2-micro \
--tags=ssh,http,rules \
--network=mynetwork

gcloud compute instances create mynet-second-vm \
--zone=$ZONE1 \
--machine-type=e2-micro \
--tags=ssh,http,rules \
--network=mynetwork