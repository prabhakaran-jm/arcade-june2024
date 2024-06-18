gcloud auth list
gcloud config list project
sudo apt install iputils-ping
gcloud compute networks create labnet --subnet-mode=custom
gcloud compute networks subnets create labnet-sub \
   --network labnet \
   --region us-central1 \
   --range 10.0.0.0/28
gcloud compute networks list
gcloud compute networks subnets list
gcloud compute firewall-rules create labnet-allow-internal \
	--network=labnet \
	--action=ALLOW \
	--rules=icmp,tcp:22 \
	--source-ranges=0.0.0.0/0
gcloud compute networks create privatenet --subnet-mode=custom
gcloud compute networks subnets create private-sub \
    --network=privatenet \
    --region=us-central1 \
    --range 10.1.0.0/28
gcloud compute firewall-rules create privatenet-deny \
    --network=privatenet \
    --action=DENY \
    --rules=icmp,tcp:22 \
    --source-ranges=0.0.0.0/0
gcloud compute firewall-rules list --sort-by=NETWORK
gcloud compute instances create pnet-vm \
--zone=us-central1-c \
--machine-type=n1-standard-1 \
--subnet=private-sub
gcloud compute instances create lnet-vm \
--zone=us-central1-c \
--machine-type=n1-standard-1 \
--subnet=labnet-sub
gcloud compute instances list --sort-by=ZONE