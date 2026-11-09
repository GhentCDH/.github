# Shared workflows

Reusable workflows for GhentCDH repositories. Reference them by tag (`@v1` follows the latest 1.x release).

| Workflow | Publishes to | Secrets |
|---|---|---|
| `ghcr-publish.yaml` | `ghcr.io/<image>` | none (uses the caller's `GITHUB_TOKEN`) |
| `dockerhub-publish.yaml` | `docker.io/<image>` | `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` |

Both take the same inputs, so switching registries only means changing `uses:`.

## Usage

```yaml
on:
  push:
    tags: ['v*']

jobs:
  publish:
    permissions:
      contents: read
      packages: write   # GHCR only: a called workflow cannot raise its own permissions
    uses: GhentCDH/.github/.github/workflows/ghcr-publish.yaml@v1
    with:
      image: ghentcdh/my-app
```

Docker Hub:

```yaml
jobs:
  publish:
    uses: GhentCDH/.github/.github/workflows/dockerhub-publish.yaml@v1
    with:
      image: ghentcdh/my-app
    secrets: inherit
```

## Secrets

Pass secrets with `secrets: inherit` (all caller secrets) or explicitly:

```yaml
    secrets:
      DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
      DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
```

GhentCDH is on the GitHub Free plan: organization secrets only reach **public** repositories. Private repositories need their own repository secrets.

## Inputs

| Input | Default | |
|---|---|---|
| `image` | — (required) | Image name without registry, lowercase |
| `context` | `.` | Build context |
| `file` | `<context>/Dockerfile` | Dockerfile path |
| `target` | | Multi-stage build target |
| `build-args` | | `NAME=value`, one per line |
| `platforms` | `linux/amd64` | e.g. `linux/amd64,linux/arm64` |
| `push` | `true` | `false` = build only |
| `tags` | branch, pr, semver | `docker/metadata-action` tag rules |
| `flavor` | `latest=auto` | `docker/metadata-action` flavor |

Outputs: `tags`, `digest`.

## Resulting tags

| Trigger | Tags |
|---|---|
| tag `v1.2.3` | `1.2.3`, `1.2`, `1`, `latest` (no `latest` for pre-releases) |
| branch push | `<branch>` |
| pull request | `pr-<number>` |

Build check on PRs without publishing: `push: ${{ github.event_name != 'pull_request' }}`.
