#!/bin/bash

component='proxy'
for h in $(cat ${component}.hosts); do rsync -av --no-p --no-o --no-g --chmod=ugo=rwX -e 'ssh -i  /home/k/.ssh/HelloWorld.id -l root' ${component}/* $h:/; done

component='app'
for h in $(cat ${component}.hosts); do rsync -av --no-p --no-o --no-g --chmod=ugo=rwX -e 'ssh -i  /home/k/.ssh/HelloWorld.id -l root' ${component}/* $h:/; done
