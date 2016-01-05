variable "GIT_COMMIT" {}
variable "GIT_BRANCH" {}
variable "AMI" {
    default = "ami-5189a661"
}
variable "INSTANCE_TYPE" {
    default = "m3.large"
}
variable "KEY_NAME" {
    default = "bamboo-ci"
}
variable "SECURITY_GROUP" {
    default = "DEVOPS-47-bamboo"
}
variable "REGION" {
    default = "us-west-2"
}
variable "AWS_KEYPAIR" {
    default = "bamboo-ci.pem"
}

provider "aws" {
    region = "${var.REGION}"
}

resource "aws_instance" "bamboo-server" {
    ami = "${var.AMI}"
    instance_type = "${var.INSTANCE_TYPE}"
    key_name = "${var.KEY_NAME}"
    security_groups = ["${var.SECURITY_GROUP}"]

    # Connect to remote instance as "ubuntu" using the specified AWS keypair
    connection {
        user = "ubuntu"
        key_file = "${var.AWS_KEYPAIR}"
        timeout = "1m"
    }

    # Write out public ip address for later use
    provisioner "local-exec" {
        command = "echo ${aws_instance.bamboo-server.public_ip} > public_ip.txt"
    }

    # Install salt stack dependencies
    provisioner "remote-exec" {
        inline = [
            "wget -O - https://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -",
            "echo 'deb http://repo.saltstack.com/apt/ubuntu/14.04/amd64/latest trusty main' | sudo tee --append /etc/apt/sources.list.d/saltstack.list > /dev/null",
            "sudo apt-get update",
            "sudo apt-get install -y git",
            "sudo apt-get install -y salt-common",
            "sudo apt-get install -y salt-minion",
            "sudo apt-get install -y salt-ssh",
        ]
    }

    # Initialize empty git repository.  We'll push to it later.
    provisioner "remote-exec" {
        inline = [
            "git init bamboo-infrastructure",
            "(cd bamboo-infrastructure && git config receive.denyCurrentBranch ignore)"
        ]
    }

    # Push to remote repository
    provisioner "local-exec" {
        command = "GIT_SSH_COMMAND=\"ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${var.AWS_KEYPAIR}\" git push --force ubuntu@${aws_instance.bamboo-server.public_ip}:bamboo-infrastructure/ ${var.GIT_BRANCH}"
    }

    # Reset to desired git commit in remote repository
    provisioner "remote-exec" {
        inline = [
            "(cd bamboo-infrastructure && git reset --hard ${var.GIT_COMMIT})",
            "(cd bamboo-infrastructure/bamboo-server/vendor && cat atlassian-bamboo-5.9.7.tar.gz-* > atlassian-bamboo-5.9.7.tar.gz)"
        ]
    }

    # Run salt configuration management
    provisioner "remote-exec" {
        inline = [
            "sudo cp /home/ubuntu/bamboo-infrastructure/etc/salt/minion.d/minion.conf /etc/salt/minion.d/",
            "sudo salt-call --local state.highstate"
        ]
    }
}
