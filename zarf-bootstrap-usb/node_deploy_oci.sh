#!/bin/bash
# Reqs:
# - run as root (i.e. sudo)
#

# Likely taken care of prior to this script (remove after integrating with other's work)
wget https://github.com/defenseunicorns/zarf/releases/download/v0.26.1/zarf_v0.26.1_Linux_amd64
wget https://github.com/defenseunicorns/zarf/releases/download/v0.26.1/zarf-init-amd64-v0.26.1.tar.zst
chmod +x zarf_v0.26.1_Linux_amd64
sudo mv zarf_v0.26.1_Linux_amd64 /usr/local/bin/zarf

# init zarf soley for standing up cluster, this likely is taken care of prior (remove after integrating with other's work)
zarf init --components k3s --confirm

# Set up docker config json for authentication
zarf tools registry login $OCI_REGISTRY:31999 --username $PULL_USERNAME --password $PULL_PASSWORD

# Assumes zarf oci packages already published to OCI registry
zarf package deploy oci://$OCI_REGISTRY:31999/oci-registry/<package_name>:<package_version> --insecure --confirm