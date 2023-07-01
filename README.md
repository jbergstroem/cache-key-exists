# cache-exists

Peek into the Github action cache and see if a certain key exists.

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
      - uses: jbergstroem/cache-exists@v1
        id: cache_exists
        with:
          key: ${{ runner.os }}-node-deps-${{ hashFiles('**/pnpm-lock.yaml') }}

      - name: Install dependencies
        if: steps.cache_exists.outputs.cache-hit !== 'true'
        run: pnpm ci
```

## Parameters

| Variable   | Default                       | Description                                                             |
| :--------- | :---------------------------- | :---------------------------------------------------------------------- |
| key        |                               | **Required:** a string that represents your cache key (`**/Dockerfile`) |
| token      | `${{ secrets.GITHUB_TOKEN }}` | Access token to use for api authentication                              |
| repository | `${{ github.repository }}`    | The repository to use. Defaults to the current repository.              |
| fail_exit  | `false`                       | Fail the job if the key doesn't exist (`true`/`false`)                  |

## Output

You can use the output `cache-hit` to check if the key exists in the cache:

```yaml
- uses: jbergstroem/cache-exists@v1
  id: cache_exists
  with:
    key: ${{ runner.os }}-node-deps-${{ hashFiles('**/pnpm-lock.yaml') }}
```

`steps.cache_exists.outputs.cache-hit` now is either `true` or `false`

## Under the hood

The core of this action is more or less a curl one-liner - feel free to use this directly:
```shell
export KEY="${{ runner.os }}-node-deps-${{ hashFiles('package-lock.json') }}"
curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "${{ github.api_url }}/repos/${{ github.repository }}/actions/caches"?key=${KEY}" \
  | jq -r '"cache-hit=" + (.total_count > 0 | tostring)' >> "$GITHUB_OUTPUT"
```

What this action helps with is proper input validation, shell usage and logging. See it as a
more tested way of achieving the same as above.

## Development

This action is written in [Bash][bash] (needs 4 or later). It additionally uses [curl][curl] and [jq][jq]. For
testing and validation purposes, [bash_unit][bash_unit], [shellcheck][shellcheck], [actionlint][actionlint] and [typos][typos] is also required.

If you're using [Homebrew][brew], here's a oneliner:

```shell
brew install bash curl jq bash_unit shellcheck actionlint typos-cli
```

### Running tests

Run unit tests with:

```shell
bash_unit test/*.sh
```

End to end tests are run in Github Actions.

[gh-cache]: https://github.com/actions/cache
[bash]: https://www.gnu.org/software/bash/
[curl]: https://curl.se/
[jq]: https://stedolan.github.io/jq/
[bash_unit]: https://github.com/pgrange/bash_unit
[shellcheck]: https://www.shellcheck.net
[actionlint]: https://github.com/rhysd/actionlint
[typos]: https://crates.io/crates/typos-cli
[brew]: https://brew.sh
[license]: ./LICENSE
