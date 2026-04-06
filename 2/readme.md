## Add Agent Inventory to abox

This section explains how to install Agent Inventory into the same Kubernetes cluster created by abox.

### Prerequisites

- kubectl must be installed
- helm must be installed
- the abox repository must already be cloned
- discovery.yaml must exist in the root of the abox repository

### Step 1. Start abox

Open a terminal, go to the abox repository root, and start the environment:

```bash
cd /workspaces/abox
make run
```

Wait until all components are fully started.

### Step 2. Clone Agent Inventory repository

Open another terminal or go to the parent directory and clone the repository:

```bash
cd ..
git clone https://github.com/den-vasyliev/agentregistry-inventory.git
cd agentregistry-inventory
```

### Step 3. Create namespace

Create a dedicated namespace for Agent Inventory:

```bash
kubectl create namespace agentregistry --dry-run=client -o yaml | kubectl apply -f -
```

### Step 4. Apply CRDs

Install the required Custom Resource Definitions:

```bash
kubectl apply -f config/crd/
```

### Step 5. Install Agent Inventory with Helm

Deploy Agent Inventory into the abox Kubernetes cluster:

```bash
helm install agentregistry-inventory ./charts/agentregistry -n agentregistry
```

### Step 6. Apply discovery configuration in abox

Return to the abox repository and apply the discovery configuration:

```bash
cd ..
cd abox/releases
kubectl apply -f discovery.yaml
```

### Result

After completing these steps:

- Agent Inventory will be deployed in the agentregistry namespace
- abox will discover it through discovery.yaml
- the integration will be completed
