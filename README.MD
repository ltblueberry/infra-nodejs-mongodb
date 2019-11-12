# Infrastructure NodeJS MongoDB

It is an example infrastructure repository for simple NodeJS + MongoDB application.

I use my [dummy](https://github.com/ltblueberry/dummy-node-mongo) as deployment application.
It has next endpoints:
* `GET` **/** - returns "Hello world!" string.
* `GET` **/elements** - returns array from "elements" collection of mongodb database

# Dependencies
* Python
* [gcloud](https://cloud.google.com/sdk/gcloud/)
* [Packer](https://www.packer.io) (version 1.4.5)
* [Terraform](https://www.terraform.io) (version 0.11.14)

# gcloud
Our infrastucture will be located in [Google Cloud Platform](https://cloud.google.com). To automate infrastructure configuration we need to install [**gcloud**](https://cloud.google.com/sdk/docs/downloads-versioned-archives) cli, so we can provide other tools access to our cloud. [Authorize with gcloud cli](https://cloud.google.com/sdk/gcloud/reference/auth/). Also make service key in json format (*GCP Console -> IAM -> Service Accounts -> Select account -> Create Key -> JSON*), it will be used in next steps.

# SSH-key
Create ssh-key for connecting to the cloud. In this example it is `~/.ssh/gcloud_rsa`. Add it to *GCP Console -> Compute Engine -> Metadata* for `appuser` user.

# Packer
HashiCorp Packer automates the creation of our base machine images. There are 2 templates for base images (with NodeJS and MongoDB) in **packer** directory. They do not have provisioners yet, provisioners will be added in next steps.
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
