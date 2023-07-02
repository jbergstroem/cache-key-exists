#!/usr/bin/env bash

function run_curl() {
  # ${1}: url
  # ${2}: token
  # ${3}: key
  local result=$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${2}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "${1}?key=${3}")
  echo "${result}"
}
