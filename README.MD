# Infrastructure NodeJS MongoDB

It is an example infrastructure repository for simple NodeJS + MongoDB application.

I use my [dummy](https://github.com/ltblueberry/dummy-node-mongo) as deployment application.
It has next endpoints:
* `GET` **/** - returns "Hello world!" string.
* `GET` **/elements** - returns array from "elements" collection of mongodb database

# Dependencies
* Python
* pip
* [gcloud](https://cloud.google.com/sdk/gcloud/)
* [Packer](https://www.packer.io) (version 1.4.5)
* [Terraform](https://www.terraform.io) (version 0.11.14)
* [Ansible](https://www.ansible.com) (version 2.9.0)
* VirtualBox and [Vagrant](https://www.vagrantup.com)

# gcloud
Our infrastucture will be located in [Google Cloud Platform](https://cloud.google.com). To automate infrastructure configuration we need to install [**gcloud**](https://cloud.google.com/sdk/docs/downloads-versioned-archives) cli, so we can provide other tools access to our cloud. [Authorize with gcloud cli](https://cloud.google.com/sdk/gcloud/reference/auth/). Also make service key in json format (*GCP Console -> IAM -> Service Accounts -> Select account -> Create Key -> JSON*), it will be used in next steps.

# SSH-key
Create ssh-key for connecting to the cloud. In this example it is `~/.ssh/gcloud_rsa`. Add it to *GCP Console -> Compute Engine -> Metadata* for `appuser` user.

# Packer
HashiCorp Packer automates the creation of our base machine images. There are 2 templates for base images (with NodeJS and MongoDB) in **packer** directory. 
They have ansible provisioners with **ansible/playbooks/packer_mongodb.yml** and **ansible/playbooks/packer_nodejs.yml** playbooks and apply tasks with **install** tag only.

**Packer uses `appuser` user to connect via ssh. Make sure you added your ssh-key and have firewall rule for ssh connections.**

To validate templates execute next commands
```
packer validate -var "project_id=<your_gcp_project_id>" packer/nodejs-base.json
packer validate -var "project_id=<your_gcp_project_id>" packer/mongodb-base.json
```
To build images from templates execute next commands
```
packer build -var "project_id=<your_gcp_project_id>" packer/nodejs-base.json
packer build -var "project_id=<your_gcp_project_id>" packer/mongodb-base.json
```

# Terraform
HashiCorp Terraform is used to provision and manage cloud infrastructure and services. Terraform keeps the state of our cloud infrastructure in **state file**. We should keep it remote, for example in GCP Object Storage.

Let's make Object Storage bucket for this.
Replace **terraform.tfvars.example** file with **terraform.tfvars** file with your variables. Execute next commands in **terraform/backend-bucket** directory
```
terraform init
terraform apply
```
Terraform creates bucket (example name is `infra-nodejs-mongodb-89p13-terraform-state`) where we will keep our main terraform configuration state.

In **terraform/modules** directory we have next modules:
* **app** - module that creates app instance from Packer **nodejs-base** image, reserve IP address and creates firewall rules that allow connections to 80 and 3000 ports
* **db** - module that creates db instance from Packer **mongodb-base** image and creates firewall rule that allow connections from app instance to 27017 port
* **vpc** - module that creates firewall rule that allow SSH conections to app and db instances

In **terraform/stage** and In **terraform/prod** directory directory we have configuration for environments. Differences between them are allowed IP address for SSH connections (for prod it is only address from `my_ip` variable that is allowed)  and env prefix.

 Replace **terraform.tfvars.example** file with **terraform.tfvars** with real variables.
 
 To run stage environment change directory to **terraform/stage** and execute next commands
 ```
terraform init
terraform apply
 ```
Same for prod environment, but directory is **terraform/prod**.

You can see external IP addresses of host in output by executing next command
```
terraform output
```

# Ansible
Ansible is configuration management, and application-deployment tool. It's used to configure our hosts and deploy the application.

Install ansible and dependencies, execute next command in **ansible** directory
```
pip install -r requirements.txt
```

**ansible.cfg** is configuration file for ansible in project

There are two dynamic inventories for stage and prod in **environments** directory. **Replace `your_gcp_project_id `, `service_account_file` with your real values before start.**

Install inventory requirements with next command
```
ansible-galaxy install -r environments/stage/requirements.yml
ansible-galaxy install -r environments/prod/requirements.yml
```
*if you have error with ansible-galaxy certificate verify failed execute next command*
```
# flag -c ignore certs errors
ansible-galaxy install -r environments/stage/requirements.yml -c
ansible-galaxy install -r environments/prod/requirements.yml -c
```

There are next playbooks in **playbooks** directory:
* **base.yml** - Installs Python for Ansible
* **app.yml** - Run **app** and **nginxinc.nginx** roles at app hosts
* **db.yml** - Run **db** role at db hosts
* **deploy.yml** - Deploy application code, install dependencies and restart service
* **packer_mongodb.yml** - Used in Packer provisioner for mongodb image
* **packer_nodejs.yml** - Used in Packer provisioner for nodejs image
* **site.yml** - Configure app and db, deploy application and launch it

There are next roles in **roles** directory:
* **app** - Install NodeJS and configure systemd app.service for application
* **db** - Install MongoDB and configure it to listen 27017 port not only for localhost
* **nginxinc.nginx** - Installed via Ansible-Galaxy. It's official role from nginx. 

**Stage environment**
It is the default environment in **ansible.cfg** file, so just execute next command without specified inventory
```
# Run playbook in dry-run mode
ansible-playbook playbooks/site.yml --check

# Execute playbook
ansible-playbook playbooks/site.yml
```

**Prod environment**
```
# Run playbook in dry-run mode
ansible-playbook -i environments/prod/inventory.gcp.yml playbooks/site.yml --check

# Execute playbook
ansible-playbook -i environments/prod/inventory.gcp.yml playbooks/site.yml
```

**Vagrantfile** - vagrant config for two virtual box instances with ansible provisioners to test **site.yml** playbook localy.
Launch vagrant instances with next command
```
vagrant up

# You can ssh to vagrant instance
vagrant ssh appserver
vagrant ssh dbserver
```
Check application at **10.10.10.20** in browser. Check **10.10.10.20/elements**.

Destory vagrant instances with next command
```
vagrant destroy
```

Role **db** has molecule tests. Change directory to **roles/db**.
To create test instance execute next command
```
molecule create

# List test instances
molecule list
```
To run playbook at test instance execute next command
```
molecule converge
```
To run test execute next command
```
molecule verify
```
To destroy test instance execute next coomand
```
molecule destroy
```
