#!/bin/bash


set -xe

# https://nektosact.com/installation/gh.html
gh extension install https://github.com/nektos/gh-act
gh act workflow_dispatch # may need to docker pull catthehacker/ubuntu:act-latest for bed network

