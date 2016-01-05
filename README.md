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
