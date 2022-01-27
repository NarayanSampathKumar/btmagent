#!/bin/bash
set -x #echo on


rm -rf bundle
echo 'removed bundle'
kubectl delete -f config/rbac
kubectl delete -f config/manager
echo 'cleanup agentoper8r'
operator-sdk cleanup btmagent --delete-all=true
export GO111MODULE=on
go mod tidy
make generate
make manifests
#docker run -it --rm -v ${PWD}:/work -w /work debian bash -c "./generate_self_signed_ssl.md"
docker logout
echo "$DOCKER_PASSWORD" | docker login --username egapm --password-stdin
make docker-build docker-push
make bundle
make bundle-build bundle-push
kubectl create -f config/manager
kubectl create -f config/rbac
operator-sdk run bundle 172.16.8.78:5000/btmagent-bundle:v0.0.1  --skip-tls --timeout 15m0s
