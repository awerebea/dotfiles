#! /usr/bin/env bash

fd -IH -td ".terragrunt-cache"; fd -IH -tf ".terraform.lock.hcl"
fd -IH -td ".terragrunt-cache" -x rm -rf; fd -IH -tf ".terraform.lock.hcl" -x rm
