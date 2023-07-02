#!/usr/bin/env bash

function validate_fail_exit() {
  [[ "${1}" == "true" || "${1}" == "false" ]] && return 0 || return 1
}
