MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
KIND_CONFIG := $(MAKEFILE_DIR)/kind-config.yaml
-include .env
export GEMINI_API_KEY

.PHONY: kind-start kind-delete kagent-crds-install kagent-crds-uninstall \
	kagent-install kagent-uninstall create-kagent-agentgateway-secret \
	delete-kagent-agentgateway-secret kagent-config-apply ki ku agentgateway-crd-install \
	agentgateway-crd-uninstall agentgateway-download-crds agentgateway-install \
	agentgateway-uninstall create-agentgateway-gemini-secret \
	delete-agentgateway-gemini-secret agentgateway-config-apply \
	agentgateway-config-delete ai-stack-install ai-stack-uninstall

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
	$(MAKE) kagent-config-apply

kagent-uninstall:
	helm uninstall kagent --namespace kagent --ignore-not-found

create-kagent-agentgateway-secret:
	-kubectl delete secret kagent-agentgateway -n kagent --ignore-not-found
	kubectl create secret generic kagent-agentgateway \
		--from-literal=OPENAI_API_KEY=agentgateway-local \
		-n kagent

delete-kagent-agentgateway-secret:
	kubectl delete secret kagent-agentgateway -n kagent --ignore-not-found

kagent-config-apply:
	kubectl apply -f ./devops/manifests/kagent/default-model-config.yaml

agentgateway-crd-install:
	kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml
	helm upgrade -i --create-namespace \
		--namespace agentgateway-system \
		--version v1.0.0 agentgateway-crds oci://cr.agentgateway.dev/charts/agentgateway-crds

agentgateway-crd-uninstall:
	helm uninstall agentgateway-crds --namespace agentgateway-system --ignore-not-found
	kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml --ignore-not-found

agentgateway-download-crds:
	helm template --version v1.0.0 agentgateway-crds \
	oci://cr.agentgateway.dev/charts/agentgateway-crds \
	--output-dir ./helm

agentgateway-install:
	helm upgrade -i --create-namespace -n agentgateway-system agentgateway oci://cr.agentgateway.dev/charts/agentgateway \
		--version v1.0.0 \
		-f ./devops/helm/agentgateway/values.yaml
	$(MAKE) agentgateway-config-apply

agentgateway-uninstall:
	$(MAKE) agentgateway-config-delete
	helm uninstall agentgateway -n agentgateway-system --ignore-not-found

create-agentgateway-gemini-secret:
	-kubectl delete secret agentgateway-gemini -n agentgateway-system --ignore-not-found
	kubectl create secret generic agentgateway-gemini \
		--from-literal=Authorization=$(GEMINI_API_KEY) \
		-n agentgateway-system

delete-agentgateway-gemini-secret:
	kubectl delete secret agentgateway-gemini -n agentgateway-system --ignore-not-found

agentgateway-config-apply:
	$(MAKE) create-agentgateway-gemini-secret
	kubectl apply -f ./devops/manifests/agentgateway/gateway.yaml
	kubectl apply -f ./devops/manifests/agentgateway/backend-gemini.yaml
	kubectl apply -f ./devops/manifests/agentgateway/httproute-gemini.yaml

agentgateway-config-delete:
	kubectl delete -f ./devops/manifests/agentgateway/httproute-gemini.yaml --ignore-not-found
	kubectl delete -f ./devops/manifests/agentgateway/backend-gemini.yaml --ignore-not-found
	kubectl delete -f ./devops/manifests/agentgateway/gateway.yaml --ignore-not-found
	$(MAKE) delete-agentgateway-gemini-secret

kagent-i:
	$(MAKE) create-kagent-agentgateway-secret
	$(MAKE) kagent-crds-install
	$(MAKE) kagent-install

kagent-u:
	$(MAKE) kagent-uninstall
	$(MAKE) kagent-crds-uninstall
	$(MAKE) delete-kagent-agentgateway-secret

ai-stack-install:
	$(MAKE) agentgateway-crd-install
	$(MAKE) agentgateway-install
	$(MAKE) kagent-i

ai-stack-uninstall:
	$(MAKE) kagent-u
	$(MAKE) agentgateway-uninstall
	$(MAKE) agentgateway-crd-uninstall