#!/bin/bash -x

set -x
ansible-playbook -i hosts /data/ocp-disconnected/build.yml
SUCCESS=$?
exit $SUCCESS
