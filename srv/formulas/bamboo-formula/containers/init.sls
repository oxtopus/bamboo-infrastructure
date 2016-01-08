build-bamboo-server:
  cmd.run:
    - name: sudo docker -H tcp://0.0.0.0:2375 build -t bamboo-server:latest .
    - cwd: /home/ubuntu/bamboo-infrastructure/bamboo-server

create-bamboo-network:
  cmd.run:
    - name: sudo docker -H tcp://0.0.0.0:2375 network create bamboo

run-bamboo-server:
  cmd.run:
    - name: sudo docker -H tcp://0.0.0.0:2375 run -p 8085:8085 -d -p 80:8085 -p 54663:54663 -v /bamboo:/bamboo-home --name=bamboo-server --net=bamboo bamboo-server

build-bamboo-agent:
  cmd.run:
    - name: sudo docker -H tcp://0.0.0.0:2375 build -t bamboo-agent-docker:latest .
    - cwd: /home/ubuntu/bamboo-infrastructure/bamboo-agent-docker

run-bamboo-agent:
  cmd.run:
    - name: sudo docker -H tcp://0.0.0.0:2375 run -e HOME=/root/ -e BAMBOO_SERVER=http://bamboo-server:8085 --net=bamboo -d bamboo-agent-docker:latest
