#!/bin/bash
gcloud compute firewall-rules delete open-access --quiet
gcloud compute instances add-tags bastion --tags=$SSH_IAP_Network_tag --zone=$ZONE
gcloud compute instances start bastion --zone=$ZONE
gcloud compute firewall-rules create gsp322 \
    --action=ALLOW \
    --network=acme-vpc \
    --rules=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --target-tags=$SSH_IAP_Network_tag \
    --description="Allow SSH from IAP service" 
gcloud compute instances add-tags bastion --tags=$SSH_IAP_Network_tag --zone=$ZONE
gcloud compute firewall-rules create gsp3221 \
    --action=ALLOW \
    --network=acme-vpc \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=$HTTP_Network_Tag 
gcloud compute instances add-tags juice-shop --tags=$HTTP_Network_Tag --zone=$ZONE
gcloud compute firewall-rules create gsp3222 \
    --action=ALLOW \
    --network=acme-vpc \
    --rules=tcp:22 \
    --source-ranges=192.168.10.0/24 \
    --target-tags=$SSH_Internal_Network_tag 
gcloud compute instances add-tags juice-shop --tags=$SSH_Internal_Network_tag --zone=$ZONE
gcloud compute ssh bastion --zone=$ZONE --quiet