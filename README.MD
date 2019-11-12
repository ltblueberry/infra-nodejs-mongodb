# Infrastructure NodeJS MongoDB

It is an example infrastructure repository for simple NodeJS + MongoDB application.

I use my [dummy](https://github.com/ltblueberry/dummy-node-mongo) as deployment application.
It has next endpoints:
* `GET` **/** - returns "Hello world!" string.
* `GET` **/elements** - returns array from "elements" collection of mongodb database

# Dependencies
* Python
* [gcloud](https://cloud.google.com/sdk/gcloud/)
* [Packer](https://www.packer.io)

# gcloud
Our infrastucture will be located in [Google Cloud Platform](https://cloud.google.com). To automate infrastructure configuration we need to install [**gcloud**](https://cloud.google.com/sdk/docs/downloads-versioned-archives) cli, so we can provide other tools access to our cloud. [Authorize with gcloud cli](https://cloud.google.com/sdk/gcloud/reference/auth/). Also make service key in json format (*GCP Console -> IAM -> Service Accounts -> Select account -> Create Key -> JSON*), it will be used in next steps.

# SSH-key
Create ssh-key for connecting to the cloud. In this example it is `~/.ssh/gcloud_rsa`. Add it to *GCP Console -> Compute Engine -> Metadata* for `appuser` user.

# Packer
HashiCorp Packer automates the creation of our base machine images. There are 2 templates for base images (with NodeJS and MongoDB) in **packer** directory. They do not have provisioners yet, provisioners will be added in next steps.
**Packer uses `appuser` user to connect via ssh. Make sure you added your ssh-key and have firewall rule for ssh connections.**

To validate templates execute next command
```
packer validate -var "project_id=<your_gcp_project_id>" packer/nodejs-base.json
packer validate -var "project_id=<your_gcp_project_id>" packer/mongodb-base.json
```
To build images from templates execute next command
```
packer build -var "project_id=<your_gcp_project_id>" packer/nodejs-base.json
packer build -var "project_id=<your_gcp_project_id>" packer/mongodb-base.json
```
