# cache-key-exists

> **Warning**
> This action is deprecated. The official cache action has similar functionality: https://github.com/actions/cache/tree/main/restore#inputs (`lookup-only`)

Find out if a key exists in the Github Actions cache.

The default behavior of [actions/cache][gh-cache] is to download the cache if it exists and give you
an output to test against. This action allows you to bypass the download/restore part and instantly
return the result.

The output key is the same as [actions/cache][gh-cache] which makes this a drop in replacement/addition.

Licensed under [MIT][license].

## Usage

Check if a key exists in cache before installing dependencies:

```yaml
name: Test
on: pull_request

jobs:
  test:
    runs-on: ubuntu-22.04
    name: Run tests
    steps:
      - uses: actions/checkout@v3
      - uses: jbergstroem/cache-key-exists@v1
        id: cache_key_exists
        with:
          key: ${{ runner.os }}-node-deps-${{ hashFiles('pnpm-lock.yaml') }}
          token: ${{ secrets.GITHUB_TOKEN }}
          repository: ${{ github.repository }}

      - name: Install dependencies
        if: steps.cache_key_exists.outputs.cache-hit !== 'true'
        run: pnpm ci
```

## Parameters

| Variable   | Default | Required | Description                                               |
| :--------- | :------ | :------- | :-------------------------------------------------------- |
| key        |         | Yes      | A string that represents your cache key                   |
| token      |         | Yes      | Access token to use for api authentication                |
| repository |         | Yes      | Which repository to use - defaults to the current context |
| fail_exit  | `false` |          | Fail job if key is missing from cache (`true`/`false`)    |

## Output

You can use the output `cache-hit` to check if the key exists in the cache:

```yaml
- uses: jbergstroem/cache-key-exists@v1
  id: cache_key_exists
  with:
    key: ${{ runner.os }}-node-deps-${{ hashFiles('pnpm-lock.yaml') }}
```

`steps.cache_key_exists.outputs.cache-hit` now is either `true` or `false`

## Under the hood

The core of this action is [more or less a curl one-liner][curl.sh] - you can use it directly:

```shell
export KEY="${{ runner.os }}-node-deps-${{ hashFiles('pnpm-lock.yaml') }}"
curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "${{ github.api_url }}/repos/${{ github.repository }}/actions/caches?key=${KEY}" \
  | jq -r '"cache-hit=" + (.total_count > 0 | tostring)' >> "$GITHUB_OUTPUT"
```

This action additionally provides proper input validation, shell usage and logging. See it as a
battle-tested way of achieving the same as above.

## Development

This action is written in [Bash][bash] (needs 4 or later). It additionally uses [curl][curl] and
[jq][jq]. For testing and validation purposes, [bash_unit][bash_unit], [shellcheck][shellcheck],
[shfmt][shfmt], [actionlint][actionlint] and [typos][typos] are also required.

If you're using [Homebrew][brew], here's a oneliner:

```shell
brew install bash curl jq bash_unit shellcheck shfmt actionlint typos-cli
```

### Running tests

Run unit tests with:

```shell
bash_unit test/*.sh
```

End to end tests are run in Github Actions.

[gh-cache]: https://github.com/actions/cache
[curl.sh]: ./lib/curl.sh
[bash]: https://www.gnu.org/software/bash/
[curl]: https://curl.se/
[jq]: https://stedolan.github.io/jq/
[bash_unit]: https://github.com/pgrange/bash_unit
[shellcheck]: https://www.shellcheck.net
[shfmt]: https://github.com/mvdan/sh
[actionlint]: https://github.com/rhysd/actionlint
[typos]: https://crates.io/crates/typos-cli
[brew]: https://brew.sh
[license]: ./LICENSE
