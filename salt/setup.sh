#!/bin/bash

set -xe

export WORKING_DIR=$1
shift
NEXT=$@

type git || yum install -y git
type salt-call || curl -sSL https://bootstrap.saltstack.com | sh
for i in /srv/salt /srv/pillar /etc/salt /root/.vim ; do
  [[ -d $i ]] || mkdir -p $i
done
mountpoint -q /srv/salt || mount -B ${WORKING_DIR}/salt /srv/salt
mountpoint -q /srv/pillar || mount -B ${WORKING_DIR}/pillar /srv/pillar
mountpoint -q /etc/salt || mount -B ${WORKING_DIR}/config /etc/salt
mountpoint -q /root/.vim || mount -B ${WORKING_DIR}/salt-vim /root/.vim

[[ ! -z $NEXT ]] && eval $NEXT
