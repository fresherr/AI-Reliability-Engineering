MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
KIND_CONFIG := $(MAKEFILE_DIR)/kind-config.yaml
-include .env
export GEMINI_API_KEY

.PHONY: kind-start kind-delete kagent-crds-install kagent-crds-uninstall kagent-install kagent-uninstall create-gemini-secret ki ku

kind-start:
	kind create cluster --config "$(KIND_CONFIG)"

kind-delete:
	kind delete cluster

kagent-crds-install:
	helm upgrade --install kagent-crds oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
		--namespace kagent --create-namespace \
		-f ./devops/helm/kagent-crd/values.yaml

kagent-crds-uninstall:
	helm uninstall kagent-crds --namespace kagent

kagent-install:
	helm upgrade --install kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent \
		--namespace kagent --create-namespace \
		-f ./devops/helm/kagent/values.yaml

kagent-uninstall:
	helm uninstall kagent --namespace kagent

create-gemini-secret:
	kubectl create secret generic kagent-gemini \
		--from-literal=GOOGLE_API_KEY=$(GEMINI_API_KEY) \
		-n kagent

delete-gemini-secret:
	kubectl delete secret kagent-gemini -n kagent

ki:
	$(MAKE) create-gemini-secret
	$(MAKE) kagent-crds-install
	$(MAKE) kagent-install

ku:
	$(MAKE) kagent-uninstall
	$(MAKE) kagent-crds-uninstall
	$(MAKE) delete-gemini-secret

