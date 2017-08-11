Creating an AMI for CaseCompanion
======================================
```bash
# 1. install packer
brew install packer
packer -v # I'm using version 1.0.2.
# Packer version 1.0.3 IS BROKEN - https://github.com/hashicorp/packer/issues/5142

# 2. install ansible
brew install ansible
ansible --version # I'm using 2.3.1.0 with Python 2.7.13

# 3. download ansible roles
ansible-galaxy install -r roles.yml

# 3. configure AWS credentials
cp variables.json.example variables.json
#   follow the instructions here:
#   https://www.packer.io/docs/builders/amazon.html#specifying-amazon-credentials
#   then, put the variables in `variables.json`

# 4. Get the Ansible secrets file and password from Tom/LastPass
# copy it into deploy/create-ami/secrets.yml

# 5. Run packer!
# this will build locally in Docker (great for testing without AWS lag):
packer build -var-file variables.json packer-docker.json
# or, this will build an actual AMI on AWS:
packer build -var-file variables.json packer.json
```
