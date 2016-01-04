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
            "sudo apt-get install -y salt-common",
            "sudo apt-get install -y salt-minion",
            "sudo apt-get install -y salt-ssh",
        ]

    }

    provisioner "remote-exec" {
        inline = [
            "mkdir -p /home/ubuntu/stage/etc",
            "mkdir -p /home/ubuntu/stage/srv",
        ]
    }

    provisioner "file" {
        source = "etc/"
        destination = "/home/ubuntu/stage/etc"
    }

    provisioner "file" {
        source = "srv/"
        destination = "/home/ubuntu/stage/srv"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo cp /home/ubuntu/stage/etc/salt/minion.d/minion.conf /etc/salt/minion.d/",
            "sudo cp -r /home/ubuntu/stage/srv/* /srv/",
            "sudo salt-call --local state.highstate"
        ]
    }

    connection {
        user = "ubuntu"
        key_file = "bamboo-ci.pem"
        timeout = "1m"
    }
}
