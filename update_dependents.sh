#!/usr/bin/env bash

helm repo add gitlab https://charts.gitlab.io/

for f in `ls -l | grep ^d | cut -d ":" -f2|cut -d ' ' -f2`; do
  helm dependency update $f
done
