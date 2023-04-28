#!/bin/sh

# This script is used to add a user to the MAAS server
# and initialize MAAS for use.

maas init --admin-username admin --admin-password admin --admin-email 'x@x.com' --rbac_url="" --candid-agent-file=""
maas createadmin --username admin --password admin --email "x@x.com"
systemctl disable runonce.service
