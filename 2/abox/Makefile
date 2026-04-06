help:
	@echo "Available targets:"
	@echo "  run    - Bootstrap the full environment (install tools, provision cluster)"
	@echo "  down   - Destroy the cluster and all resources"
	@echo "  push   - Bump patch version, tag, and push to trigger CI"
	@echo "  tools  - Install necessary tools only"
	@echo "  destroy - Alias for down (destroy infra)"
	@echo "  tofu   - Initialize OpenTofu"
	@echo "  apply  - Apply OpenTofu configuration"

run:
	@bash scripts/setup.sh

# Load local env if present
-include .env
export GEMINI_API_KEY
export OPENAI_API_KEY

.PHONY: create-kagent-agentgateway-secret create-agentgateway-gemini-secret create-secrets

create-kagent-agentgateway-secret:
	-@kubectl delete secret kagent-agentgateway -n kagent --ignore-not-found
	@kubectl create secret generic kagent-agentgateway \
		--from-literal=OPENAI_API_KEY=$(if $(OPENAI_API_KEY),$(OPENAI_API_KEY),agentgateway-local) \
		-n kagent

create-agentgateway-gemini-secret:
	-@kubectl delete secret agentgateway-gemini -n agentgateway-system --ignore-not-found
	@kubectl create secret generic agentgateway-gemini \
		--from-literal=Authorization=$(GEMINI_API_KEY) \
		-n agentgateway-system

create-secrets: create-kagent-agentgateway-secret create-agentgateway-gemini-secret


tools:
ifeq ($(OS),Windows_NT)
	@echo "Detected Windows: using PowerShell helper script to manage installers"
	@powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-tools.ps1
else
	@curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method standalone
	@curl -sS https://webi.sh/k9s | bash
endif

tofu:
	@cd bootstrap && tofu init

apply:
	@cd bootstrap && tofu apply -auto-approve

down:
	@cd bootstrap && tofu destroy -auto-approve

destroy:
	@$(MAKE) down

push:
	@git fetch origin --tags --force
	$(eval TAG=$(shell git tag --list 'v*' | sort -V | tail -1 | sed 's/^v//' || echo "0.0.0"))
	$(eval MAJOR=$(shell echo $(TAG) | cut -d. -f1))
	$(eval MINOR=$(shell echo $(TAG) | cut -d. -f2))
	$(eval PATCH=$(shell echo $(TAG) | cut -d. -f3))
	$(eval NEW_TAG=v$(MAJOR).$(MINOR).$(shell echo $$(($(PATCH)+1))))
	@git tag $(NEW_TAG)
	@git push origin main $(NEW_TAG)
	@echo "Tagged and pushed $(NEW_TAG)"
