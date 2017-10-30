# Webtalk DevOps

Welcome to the Webtalk DevOps repository. This is a collection of utilities to manage the infrastructure required to run Webtalk applications.

## Features
This project is mainly meant to provide code that would allow developers to easily deploy Webtalk applications to various cloud providers, complete with configuring SSL encryption using [Let's Encrypt](https://letsencrypt.org/).

Only the Vagrant - Chef - AWS workflow is supported at the moment.

## Configuration
Configuration of the deployment code is supported via environment variables. The required variables are described below.

- `WEBTALK_AWS_ACCESS_KEY_ID` - AWS API [access key id](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys)
- `WEBTALK_AWS_SECRET_ACCESS_KEY` - AWS API [secret access key](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys)
- `WEBTALK_AWS_KEYPAIR_NAME` - AWS EC2 [keypair name](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#key-pairs)
- `WEBTALK_AWS_DEFAULT_REGION` - AWS [region](http://docs.aws.amazon.com/general/latest/gr/rande.html) to deploy to
- `WEBTALK_AWS_ELASTIC_IP` - AWS EC2 [elastic ip](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) to use for the instance launched.
- `WEBTALK_AWS_INSTANCE_TYPE` - AWS EC2 [instance type](https://aws.amazon.com/ec2/instance-types/) to use for deployment.
- `WEBTALK_AWS_AMI` - AWS EC2 [machine image](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) to use for deployment (only tested on Ubuntu 16.04 AMIs).
- `WEBTALK_SOURCE_URL` - URL to download the application code from.
- `WEBTALK_SERVER_NAME` - Server name that the application will be accessible at (e.g. `example.com`).
- `WEBTALK_ACME_CONTACT` - Contact email address required by the [ACME protocol](https://letsencrypt.org/how-it-works/) for automatically generating certificates from Let's Encrypt.
- `WEBTALK_LOGTALK_VERSION` - [Logtalk](http://logtalk.org/) version the application is based on.

## Usage
Use the steps specific to your deployment workflow, after configuring the environment variables.

#### Vagrant - Chef - AWS
```shell
$ git clone https://github.com/sandogeorge/webtalk-ops.git
$ cd webtalk-ops/vagrant
$ vagrant up --provider=aws
```