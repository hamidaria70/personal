#!/bin/bash
set -ex

source /builds/hamid.aria/dolphin/auto-deploy/deployment-variables-phase1.sh
echo "Make wheel from current version"
git checkout "v$VERSION"
python3.6 setup.py bdist_wheel

echo "Make wheel from new version"
git checkout $NEW_REF
python3.6 setup.py bdist_wheel

echo "List of .whl files..."
ls dist

