#!/usr/bin/env bash_unit

# shellcheck source=test/fixtures/curl_responses.sh
. fixtures/curl_responses.sh

# shellcheck source=lib/main.sh
. ../lib/main.sh
# shellcheck source=lib/curl.sh
. ../lib/curl.sh

test_should_output_versions() {
  local retval
  retval="$(run)"
  assert_matches ".*Using bash.*" "$retval"
  assert_matches ".*Using curl.*" "$retval"
  assert_matches ".*Using jq.*" "$retval"
}

test_should_fail_on_missing_key() {
  local retval
  retval="$(run)"
  assert_status_code 1 run
  assert_matches ".*Missing cache key. Set it and try again." "$retval"
}

test_should_fail_on_missing_token() {
  export key="foo"
  local retval
  retval="$(run)"
  assert_status_code 1 run
  assert_matches ".*Missing token for authentication. Set it and try again." "$retval"
  unset key
}

test_should_fail_on_missing_repository() {
  export key="foo" token="bar"
  local retval
  retval="$(run)"
  assert_status_code 1 run
  assert_matches ".*Missing repository to check cache for. Set it and try again." "$retval"
  unset key token
}

test_validate_fail_exit() {
  assert "validate_fail_exit true"
  assert "validate_fail_exit false"
  assert_fail "validate_fail_exit ok"
}

test_cache_hit() {
  export -f mock_cache_hit
  fake run_curl mock_cache_hit
  export key="foo" repository="test/repo" token="temp"
  local retval
  retval="$(run)"
  assert_status_code 0 run
  assert_matches ".*found a cache.*" "$retval"
  unset key token repository mock_cache_hit
}

test_cache_miss() {
  export -f mock_cache_miss
  fake run_curl mock_cache_miss
  export key="foo" repository="test/repo" token="temp"
  local retval
  retval="$(run)"
  assert_status_code 0 run
  assert_matches ".*could not find a cache.*" "$retval"
  unset key token repository mock_cache_miss
}

test_cache_miss_with_exit_fail() {
  export -f mock_cache_miss
  fake run_curl mock_cache_miss
  export key="foo" repository="test/repo" token="temp"
  export fail_exit=true
  local retval
  retval="$(run)"
  assert_status_code 1 run
  assert_matches ".*could not find a cache.*" "$retval"
  unset key token repository fail_exit mock_cache_miss
}

test_invalid_repository() {
  export -f mock_invalid_repo
  fake run_curl mock_invalid_repo
  export key="foo" repository="test/repo" token="temp"
  local retval
  retval="$(run)"
  assert_status_code 0 run
  assert_matches ".*could not retrieve cache results: Not Found.*" "$retval"
  unset key token repository mock_invalid_repo
}
