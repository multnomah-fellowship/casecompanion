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

# 4. Get the Ansible secrets file and password from Tom
# copy it into deploy/create-ami/secrets.yml
# put the decryption password in `variables.json` from step 3 under "ansible_vault_password".

# 5. Run packer!
# this will build locally in Docker (great for testing without AWS lag):
make docker

# or, this will build an actual AMI on AWS:
make ami
```

# Updating an application secret
To change the value of an application secret, first edit the Ansible vault locally and then deploy the change by building a new AMI and reprovisioning the servers using the new AMI.

The command to edit the vault locally is (in the deploy/create-ami directory):

```bash
ansible-vault edit --vault-password-file ./.ansible_vault_password.py secrets.yml
```

If you don't have the secrets.yml file, you will need to get it from the current maintainer of the application.
