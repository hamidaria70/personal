#!/bin/bash
set -e

SERVER_HOST="192.168.1.51"
VERSION=$(curl -s $SERVER_HOST/apiv1/version \
	|grep -i version | cut -d ":" -f 2 | cut -d '"' -f 2)
echo "Make wheel from current version"
git checkout "v$VERSION"
python3.6 setup.py bdist_wheel

echo "Make wheel from new version"
git checkout develop
python3.6 setup.py bdist_wheel

echo "List of .whl files..."
ls dist

