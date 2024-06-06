#!/bin/bash
gsutil mb -l $REGION -c Standard gs://$DEVSHELL_PROJECT_ID
curl -o kitten.png https://cdn.qwiklabs.com/8tnHNHkj30vDqnzokQ%2FcKrxmOLoxgfaswd9nuZkEjd8%3D
gsutil cp kitten.png gs://$DEVSHELL_PROJECT_ID/kitten.png
gsutil iam ch allUsers:objectViewer gs://$DEVSHELL_PROJECT_ID
