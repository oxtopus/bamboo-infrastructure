mount-bamboo-ebs:
  cmd.run:
    - name: /home/ubuntu/bamboo-infrastructure/srv/formulas/bamboo-formula/scripts/mount-bamboo-ebs.sh

mount-docker-ebs:
  cmd.run:
    - name: /home/ubuntu/bamboo-infrastructure/srv/formulas/bamboo-formula/scripts/mount-docker-ebs.sh
