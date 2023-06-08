#!/bin/bash
# Reqs:
# - must be ran as root (sudo will not suffice!) see zarf docs for additional info:
# - https://docs.zarf.dev/docs/walkthroughs/creating-a-k8s-cluster-with-zarf
#

# Likely taken care of prior to this script (remove after integrating with other's work)
wget https://github.com/defenseunicorns/zarf/releases/download/v0.27.2/zarf_v0.27.2_Linux_amd64
wget https://github.com/defenseunicorns/zarf/releases/download/v0.27.2/zarf-init-amd64-v0.27.2.tar.zst
chmod +x zarf_v0.27.2_Linux_amd64
sudo mv zarf_v0.27.2_Linux_amd64 /usr/local/bin/zarf

# init zarf (to deploy k3s and zarf's registry - deploying git server as well)
zarf init --components k3s,git-server --confirm

# Need jq for this
PUSH_USERNAME=$(kubectl get secret -n zarf zarf-state -o jsonpath='{.data.state}' | base64 -d | jq -r '.registryInfo.pushUsername')
PUSH_PASSWORD=$(kubectl get secret -n zarf zarf-state -o jsonpath='{.data.state}' | base64 -d | jq -r '.registryInfo.pushPassword')
PULL_USERNAME=$(kubectl get secret -n zarf zarf-state -o jsonpath='{.data.state}' | base64 -d | jq -r '.registryInfo.pullUsername')
PULL_PASSWORD=$(kubectl get secret -n zarf zarf-state -o jsonpath='{.data.state}' | base64 -d | jq -r '.registryInfo.pullPassword')

# Set up docker config json for authentication
zarf tools registry login 127.0.0.1:31999 --username $PUSH_USERNAME --password $PUSH_PASSWORD

# Assumes zarf zst files exist locally AND the package(s) is/are built with version defined (required to publish to OCI)
zarf package publish zarf-package-*.tar.zst oci://127.0.0.1:31999/oci-registry --insecure

# TODO: need to determine how to 'give' the $PULL_USERNAME, $PULL_PASSWORD and $OCI_REGISTRY (ip address) to the nodes