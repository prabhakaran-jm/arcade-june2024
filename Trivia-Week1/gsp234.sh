#!/bin/bash

mkdir sql-with-terraform

cd sql-with-terraform

gsutil cp -r gs://spls/gsp234/gsp234.zip .

unzip gsp234.zip

cat main.tf

terraform init

terraform plan -out=tfplan

terraform apply tfplan

