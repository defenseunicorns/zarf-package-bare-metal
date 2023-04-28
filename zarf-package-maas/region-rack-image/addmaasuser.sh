#!/bin/sh

# This script is used to add a user to the MAAS server
# and initialize MAAS for use.

maas init --admin-username ${ADMIN_USER} --admin-password ${ADMIN_PASS} --rbac_url="" --candid-agent-file=""
systemctl disable runonce.service
