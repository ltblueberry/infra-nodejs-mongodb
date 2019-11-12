# Infrastructure NodeJS MongoDB

It is an example infrastructure repository for simple NodeJS + MongoDB application.

I use my [dummy](https://github.com/ltblueberry/dummy-node-mongo) as deployment application.
It has next endpoints:
* `GET` **/** - returns "Hello world!" string.
* `GET` **/elements** - returns array from "elements" collection of mongodb database

# Dependencies
* Python
* [gcloud](https://cloud.google.com/sdk/gcloud/)

# gcloud
Our infrastucture will be located in [Google Cloud Platform](https://cloud.google.com). To automate infrastructure configuration we need to install [**gcloud**](https://cloud.google.com/sdk/docs/downloads-versioned-archives) cli, so we can provide other tools access to our cloud. [Authorize with gcloud cli](https://cloud.google.com/sdk/gcloud/reference/auth/). Also make service key in json format (*GCP Console -> IAM -> Service Accounts -> Select account -> Create Key -> JSON*), it will be used in next steps.