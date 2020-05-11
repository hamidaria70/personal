#!/bin/bash

# Define varibales as hardcode to use.                                         
# Phase 1
set -e

SERVER_HOST="192.168.1.52"
VERSION=$(curl -s $SERVER_HOST/apiv1/version \
    |grep -i version | cut -d ":" -f 2 | cut -d '"' -f 2)

echo $VERSION
