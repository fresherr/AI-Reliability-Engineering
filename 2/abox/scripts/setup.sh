#!/bin/bash
set -euo pipefail

LOG=/tmp/setup.log
exec > >(tee -a "$LOG") 2>&1

log() { echo "[$(date '+%H:%M:%S')] $*"; }

log "=== k8sdiy-env setup start ==="

# Install OpenTofu
log "Installing OpenTofu..."
curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method standalone
log "OpenTofu installed"

# Install K9s
log "Installing K9s..."
curl -sS https://webi.sh/k9s | sh
log "K9s installed"

# Add aliases to bashrc
# Append aliases to ~/.bashrc with markers so cleanup can remove them
if ! grep -q "# k8sdiy-env aliases START" ~/.bashrc 2>/dev/null; then
cat >> ~/.bashrc <<'EOF'

# k8sdiy-env aliases START
alias kk="EDITOR='code --wait' k9s"
alias tf=tofu
alias k=kubectl
# k8sdiy-env aliases END
EOF
else
  log "Aliases already present in ~/.bashrc"
fi

# Initialize Tofu
log "Running tofu init..."
cd bootstrap
tofu init
log "tofu init done"

log "Running tofu apply..."
tofu apply -auto-approve
log "tofu apply done"

export KUBECONFIG=~/.kube/config

cd ..

# Install cloud-provider-kind (LoadBalancer support)
log "Installing cloud-provider-kind..."
ARCH=$(dpkg --print-architecture)
wget -q "https://github.com/kubernetes-sigs/cloud-provider-kind/releases/download/v0.6.0/cloud-provider-kind_0.6.0_linux_${ARCH}.tar.gz" \
  -O /tmp/cloud-provider-kind.tar.gz
tar -xzf /tmp/cloud-provider-kind.tar.gz -C /tmp cloud-provider-kind
rm /tmp/cloud-provider-kind.tar.gz
nohup /tmp/cloud-provider-kind > /tmp/cloud-provider-kind.log 2>&1 &
CPK_PID=$!
echo $CPK_PID > /tmp/cloud-provider-kind.pid
log "cloud-provider-kind started (pid $CPK_PID)"


log "=== setup complete ==="
