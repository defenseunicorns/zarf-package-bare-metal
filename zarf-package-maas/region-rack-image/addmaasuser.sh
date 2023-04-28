#!/bin/sh

# This script is used to add a user to the MAAS server
# and initialize MAAS for use.

maas init --admin-username admin --admin-password admin --admin-email 'x@x.com' --rbac-url="" --candid-agent-file=""
systemctl disable runonce.service
