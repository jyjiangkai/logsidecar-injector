REPO ?= kubespheredev/log-sidecar-injector
TAG ?= 1.1
SERVICE_NAME ?= logsidecar-injector-admission
NAMESPACE ?= kubesphere-logging-system

ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

# Run go fmt against code
fmt:
	go fmt ./...

# Run go vet against code
vet:
	go vet ./...

# Build the docker image
docker-build:
	docker build -t $(REPO):latest -t $(REPO):$(TAG) .

# Push the docker image
docker-push:
	docker push $(REPO):latest
	docker push $(REPO):$(TAG)

deploy: generate
	kubectl apply -f config/bundle.yaml

ca-secret:
	./hack/certs.sh --service $(SERVICE_NAME) --namespace $(NAMESPACE)

update-cert: ca-secret
	./hack/update-cert.sh

generate:
	cd config && /snap/bin/kustomize edit set image injector=$(REPO):$(TAG)
	/snap/bin/kustomize build config > config/bundle.yaml
