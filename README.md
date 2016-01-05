Usage
-----

*You must have [terraform](https://terraform.io/) installed the `terraform`
command in your path.*

```
terraform apply \
  -var 'access_key=${AWS_ACCESS_KEY_ID}' \
  -var 'secret_key=${AWS_SECRET_ACCESS_KEY}' \
  -var 'GIT_COMMIT=`git rev-parse --abbrev-ref HEAD`' \
  -var 'GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`'
```

`${AWS_ACCESS_KEY_ID}` and `${AWS_ACCESS_KEY_ID}` above represent environment
variables that hold credentials for the `bamboo-ci` AWS user.

In order to login via ssh, you must have the bamboo-ci keypair credentials and
then issue this command:

```
ssh -i bamboo-ci.pem ubuntu@`cat public_ip.txt`
```

Organization
------------

This repository contains the configurations for launching an instance and
configuring it to run
[Atlassian Bamboo](https://www.atlassian.com/software/bamboo/) using a
combination of tools including [Terraform](https://terraform.io/),
[Salt](http://saltstack.com/), and [Docker](https://www.docker.com/).  This
combination of tools is used to fully automate the process using code and
configuration that can be tracked in git.

`main.tf` is the terraform configuration file.  `terraform apply` uses it to
start and bootstrap a new remote AWS EC2 instance from a base Ubuntu image.

Configuration management is handled by [Salt](http://saltstack.com/), and its
primary function in this context is to install and configure Docker, the
runtime environment in which bamboo operates.  In this instance, salt is
configured to operate in local masterless mode.  During the
`terraform apply` process, `etc/salt/minion.d/minion.conf` is copied to
`/etc/salt/minion.d/minion.conf`, which instructs the salt agent to look in
`/home/ubuntu/bamboo-infrastructure/srv/salt` and
`/home/ubuntu/bamboo-infrastructure/srv/formulas/docker-formula` for formulas.
The salt configuration can be found in this repository at `srv/salt/top.sls`.
