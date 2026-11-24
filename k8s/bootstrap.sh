#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

gcloud container clusters get-credentials voting-lab \
  --project=voting-app-devops-gcp \
  --zone=europe-west1-b

kubectl -n default apply \
  -f k8s/voting-demo.yml \
  -f k8s-specifications/db-service.yaml \
  -f k8s-specifications/db-deployment.yaml \
  -f k8s-specifications/result-deployment.yaml \
  -f k8s-specifications/worker-deployment.yaml \
  -f k8s/deploy-rbac.yml \
  -f k8s/public-services.yml

for deployment in db redis worker vote result; do
  kubectl -n default rollout status "deployment/$deployment" --timeout=180s
done

kubectl -n default get svc vote-public result-public