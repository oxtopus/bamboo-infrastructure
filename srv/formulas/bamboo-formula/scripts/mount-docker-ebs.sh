#!/bin/bash
# ----------------------------------------------------------------------
# Numenta Platform for Intelligent Computing (NuPIC)
# Copyright (C) 2015, Numenta, Inc.  Unless you have purchased from
# Numenta, Inc. a separate commercial license for this software code, the
# following terms and conditions apply:
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero Public License for more details.
#
# You should have received a copy of the GNU Affero Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# http://numenta.org/licenses/
# ----------------------------------------------------------------------
#

set -o errexit
set -o pipefail

[[ $(sudo file -s /dev/xvdi) == "/dev/xvdi: data" ]] && sudo mkfs -t ext4 /dev/xvdi
sudo mkdir -p /var/lib/docker
FSTAB_ENTRY="/dev/xvdi /var/lib/docker ext4 defaults,nofail,nobootwait 0 2" && grep -q "$FSTAB_ENTRY" /etc/fstab || (echo $FSTAB_ENTRY | sudo tee --append /etc/fstab > /dev/null)
sudo mount -a
