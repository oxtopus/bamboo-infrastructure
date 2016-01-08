Bamboo Infrastructure
=====================

Herein lies the infrastructure configuration for
[Atlassian Bamboo](https://www.atlassian.com/software/bamboo/).  A combination
of tools is used to provision AWS resources, configure an instance, and run
processes.  [terraform](https://terraform.io/), is used to provision AWS
resources such as EC2 instance and EBS volumes by way of a declarative
configuration file (see `main.tf`).  [Salt](http://saltstack.com/), another
declarative tool, manages system-level configuration.  In our case, it prepares
the system to run [Docker](https://www.docker.com/), as well as Bamboo server
and agent docker containers for process isolation.

Usage
-----

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

Once up and running, the bamboo server is listening on port 8085.

Applying updates
----------------

Changes are applied with `git`, and subsequently `salt`.  All salt-related
configuration is found within this repository at `srv/` and `etc/salt/`.

1. Push changes

  ```
  GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i bamboo-ci.pem' git push --force ubuntu@${HOST}:bamboo-infrastructure/ ${GIT_BRANCH}
  ```

  Where `${HOST}` and `${GIT_BRANCH}` above refer to the host created in the
  `terraform apply` command above and the current git branch (most likely
  "master" in your case).

2. Apply changes

  ```
  ssh -i bamboo-ci.pem ubuntu@${HOST} "cd bamboo-infrastructure && git reset --hard ${GIT_COMMIT}"
  ```

  Where `${GIT_COMMIT}` above is the specific commit you wish to apply.

  Alternatively, you may log in to the instance and pull changes from github
  instead of pushing remotely.

3. Run salt

  Log into the remote instance and issue this command:

  ```
  sudo salt-call --local state.highstate
  ```

Design considerations
---------------------

EBS volumes are used for permanent storage whereas the host is regarded as
transient.  The terraform and salt configurations assume a stock ubuntu
amazon machine image (AMI), and bootstraps the system to run salt, which in
turn, runs docker and bamboo docker containers.

Once up and running, there are three primary services: Docker, Bamboo Server,
and Bamboo Agent.  Both the Bamboo Server application and agent run as separate
docker containers on the same docker network named "bamboo".  The agent image
is derived from the official atlassian bamboo agent docker image with the
docker tools installed.  This is done so that the agent itself remains
completely generic, and the runtime configuration details are managed in the
project.  As a result, there need not be any changes to infrastructure as new
projects and build plans are added.  As new platforms are added where docker,
may not be available, the agents should be implemented with the same
philosophy in mind, even though Docker may not be available.
