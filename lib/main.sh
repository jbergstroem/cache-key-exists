#!/usr/bin/env bash

GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/null}

key="${key}"
token="${token}"
repository="${repository}"
fail_exit=${fail_exit:-"false"}
github_api_url=${github_api_url:-"https://api.github.com"}

function exit_with_error() {
  echo "${1}"
  exit 1
}

function validate_fail_exit() {
  [[ "${1}" == "true" || "${1}" == "false" ]] && return 0 || return 1
}

function run() {
  for executable in bash curl jq; do
    if ! command -v "${executable}" &>/dev/null; then
      exit_with_error "Cannot find required binary ${executable}. Is it in \$PATH?"
    else
      local version=""
      if [[ "${executable}" == "bash" ]]; then
        version=${BASH_VERSION%%[^0-9.]*}
      else
        local separator="-"
        [[ "${executable}" == "curl" ]] && separator=" "
        version=$("${executable}" --version | head -n 1 | cut -d "${separator}" -f 2)
      fi
      echo "::debug::Using ${executable} ${version}"
    fi
  done

  [[ -z "${key}" ]] && exit_with_error "Missing cache key. Set it and try again."
  [[ -z "${token}" ]] && exit_with_error "Missing token for authentication. Set it and try again."
  [[ -z "${repository}" ]] && exit_with_error "Missing repository to check cache for. Set it and try again."
  validate_fail_exit "${fail_exit}" || exit_with_error "Invalid fail_exit value: ${fail_exit}"

  local url result usage_count
  echo "::notice::Looking for cache key: ${key} in ${repository}"
  url="${github_api_url}/repos/${repository}/actions/caches"
  result=$(run_curl "${url}" "${token}" "${key}")
  if [[ $(echo "${result}" | jq -r 'has("message")') == "true" ]]; then
    echo "::notice::could not retrieve cache results: $(echo "${result}" | jq -r '.message')"
    [[ "${fail_exit}" == "true" ]] && exit 1 || exit 0
  fi
  usage_count=$(echo "${result}" | jq -r '.total_count')
  if [[ ${usage_count} -eq 0 ]]; then
    echo "::notice::could not find a cache for key: ${key}"
    echo "cache-hit=false" >>"$GITHUB_OUTPUT"
    [[ "${fail_exit}" == "true" ]] && exit 1 || exit 0
  else
    local last_accessed
    last_accessed="$(echo ${result} | jq -r '.actions_caches | sort_by(.last_accessed_at) | reverse | first | .last_accessed_at')"
    echo "cache-hit=true" >>"$GITHUB_OUTPUT"
    echo "::notice::found a cache last accessed at: ${last_accessed}"
    exit 0
  fi
}
