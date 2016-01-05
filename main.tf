variable "GIT_COMMIT" {}
variable "GIT_BRANCH" {}

provider "aws" {
    region = "us-west-2"
}

resource "aws_instance" "DEVOPS-73-bamboo-server" {
    ami = "ami-5189a661"
    instance_type = "m3.large"
    key_name = "bamboo-ci"
    security_groups = ["DEVOPS-47-bamboo"]

    provisioner "local-exec" {
        command = "echo ${aws_instance.DEVOPS-73-bamboo-server.public_ip} > public_ip.txt"
    }

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

    provisioner "remote-exec" {
        inline = [
            "git init bamboo-infrastructure",
            "(cd bamboo-infrastructure && git config receive.denyCurrentBranch ignore)"
        ]
    }

    provisioner "local-exec" {
        command = "GIT_SSH_COMMAND=\"ssh -i bamboo-ci.pem\" git push --force ubuntu@${aws_instance.DEVOPS-73-bamboo-server.public_ip}:bamboo-infrastructure/ ${var.GIT_BRANCH}"
    }

    provisioner "remote-exec" {
        inline = [
            "(cd bamboo-infrastructure && git reset --hard ${var.GIT_COMMIT})"
        ]
    }

    provisioner "remote-exec" {
        inline = [
            "sudo cp /home/ubuntu/bamboo-infrastructure/etc/salt/minion.d/minion.conf /etc/salt/minion.d/",
            "sudo salt-call --local state.highstate"
        ]
    }

    connection {
        user = "ubuntu"
        key_file = "bamboo-ci.pem"
        timeout = "1m"
    }
}
