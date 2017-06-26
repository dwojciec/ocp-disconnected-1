#!/bin/bash -x

set -x
ansible-playbook -i hosts build.yml
SUCCESS=$?
exit $SUCCESS
