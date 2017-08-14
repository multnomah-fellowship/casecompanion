#!/usr/bin/env python

# Parse out the Ansible vault password from the Packer variables file.
import json
import os
path = os.path.normpath(os.path.join(__file__, "..", "variables.json"))
data = json.loads(open(path, "r").read())
print(data['ansible_vault_password'])
