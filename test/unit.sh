#!/usr/bin/env bash_unit

mock_cache_hit='{
  "total_count": 3,
  "actions_caches": [
    {
      "id": 2268,
      "ref": "refs/heads/main",
      "key": "Linux-node-deps-66c80c704b22f55d06ef1ad78525ab309593e84848c4d8e9718d1edadbd6f811",
      "version": "25e65b70d167147605b4332eb57b6d34df8e0303b88c4de252efb18cf3ed148a",
      "last_accessed_at": "2023-06-30T21:40:29.876666700Z",
      "created_at": "2023-06-30T14:02:52.896666700Z",
      "size_in_bytes": 151366377
    },
    {
      "id": 2271,
      "ref": "refs/pull/15/merge",
      "key": "Linux-node-deps-66c80c704b22f55d06ef1ad78525ab309593e84848c4d8e9718d1edadbd6f811",
      "version": "25e65b70d167147605b4332eb57b6d34df8e0303b88c4de252efb18cf3ed148a",
      "last_accessed_at": "2023-06-30T15:15:22.510000000Z",
      "created_at": "2023-06-30T14:30:26.450000000Z",
      "size_in_bytes": 151376214
    },
    {
      "id": 2265,
      "ref": "refs/pull/19/merge",
      "key": "Linux-node-deps-66c80c704b22f55d06ef1ad78525ab309593e84848c4d8e9718d1edadbd6f811",
      "version": "25e65b70d167147605b4332eb57b6d34df8e0303b88c4de252efb18cf3ed148a",
      "last_accessed_at": "2023-06-30T13:38:51.193333300Z",
      "created_at": "2023-06-30T02:49:20.306666700Z",
      "size_in_bytes": 151357767
    }
  ]
}'
mock_cache_miss='{
  "total_count": 0,
  "actions_caches": []
}'

mock_invalid_repo='{
  "message": "Not Found",
  "documentation_url": "https://docs.github.com/rest/actions/cache#list-github-actions-caches-for-a-repository"
}'

# shellcheck source=lib/main.sh
. ../lib/main.sh
# shellcheck source=lib/curl.sh
. ../lib/curl.sh
# shellcheck source=lib/validate.sh
. ../lib/validate.sh

test_validate_fail_exit() {
  assert "validate_fail_exit true"
  assert "validate_fail_exit false"
  assert_fail "validate_fail_exit ok"
}
