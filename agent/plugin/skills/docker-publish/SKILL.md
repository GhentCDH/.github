---
name: docker-publish
description: Create or update a GitHub Actions workflow that builds a Docker image and publishes it to the GitHub Container Registry (ghcr.io) or Docker Hub, using GhentCDH's shared reusable workflows. Use when asked for a build workflow, a CI or release pipeline for a project with a Dockerfile, to build, push, publish or release a Docker/container image, or to add a Docker build check on pull requests. Also use when an existing workflow in a GhentCDH project builds images with its own docker/build-push-action steps.
---

# Docker build and publish with the shared workflows

GhentCDH keeps reusable workflows in the `GhentCDH/.github` repository. For
building and publishing Docker images, call one of them instead of writing
`docker/login-action`, `docker/metadata-action` and `docker/build-push-action`
steps yourself:

| Registry | `uses:` | Secrets |
|---|---|---|
| ghcr.io | `GhentCDH/.github/.github/workflows/ghcr-publish.yaml@v1` | none (caller's `GITHUB_TOKEN`) |
| Docker Hub | `GhentCDH/.github/.github/workflows/dockerhub-publish.yaml@v1` | `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` |

Both take the same inputs, so switching registries only means changing `uses:`
(plus the secrets and permissions below). Always reference `@v1`: it follows
the latest 1.x release.

## Steps

1. Look at the project: the Dockerfile(s) and their build context, multi-stage
   targets, existing files in `.github/workflows/`, and the repository name
   (`git remote -v`). If there is no Dockerfile, say so and offer to write one
   first: the shared workflows only build an existing Dockerfile.
2. Pick the registry. Use what the user asked for, or what the project already
   uses (image names in README, compose files, deploy config). If nothing
   says, ask; GHCR is the simpler choice because it needs no secrets.
3. Image name: `ghentcdh/<repository>`, lowercase, without the registry.
4. Write `.github/workflows/docker-publish.yaml` (or update the existing build
   workflow) with the template below. Replace hand-written build and push
   steps for the same image with the shared workflow; keep unrelated jobs
   (tests, linting) and make the publish job `needs:` them if they exist.
5. Tell the user what triggers a publish and which tags it produces, and
   which secrets they still need to add (Docker Hub on a private repository).

## Template

Publishes on version tags and runs a build check (no push) on pull requests:

```yaml
name: Docker

on:
  push:
    tags: ['v*']
  pull_request:

jobs:
  publish:
    permissions:
      contents: read
      packages: write   # GHCR only; needed for pull request builds too
    uses: GhentCDH/.github/.github/workflows/ghcr-publish.yaml@v1
    with:
      image: ghentcdh/my-app
      push: ${{ github.event_name != 'pull_request' }}
```

Docker Hub variant of the job:

```yaml
  publish:
    uses: GhentCDH/.github/.github/workflows/dockerhub-publish.yaml@v1
    with:
      image: ghentcdh/my-app
      push: ${{ github.event_name != 'pull_request' }}
    secrets: inherit
```

Add `branches: [main]` under `push:` only when the project deploys from a
branch: every push then publishes an image tagged with the branch name.

## Rules that are easy to get wrong

- **GHCR permissions.** A called workflow cannot raise its own permissions, so
  the calling job must grant `packages: write` (and `contents: read`). The
  GHCR workflow always logs in (it reads its build cache from the registry),
  so this applies to build-only pull request runs as well.
- **Docker Hub secrets.** Pass them with `secrets: inherit`. GhentCDH is on the
  GitHub Free plan: organization secrets only reach **public** repositories.
  A private repository needs its own repository secrets `DOCKERHUB_USERNAME`
  and `DOCKERHUB_TOKEN`; tell the user to add them. A build-only run
  (`push: false`) logs in to nothing and needs no secrets.
- **No tags, no publish.** With `push: true`, the workflow fails if the event
  produces no image tags. The default tag rules cover version tags
  (`v1.2.3`), branch pushes and pull requests; for other triggers
  (`workflow_dispatch`, `schedule`, `release`) pass `tags:` rules that match
  them.
- **Several images** (several Dockerfiles or targets): one job per image, each
  calling the shared workflow with its own `image`, `context`, `file` or
  `target`.
- **Private GHCR packages.** Images published from a private repository are
  private. Pulling them on a server needs `docker login ghcr.io` with a
  classic personal access token with the `read:packages` scope (GHCR does not
  accept fine-grained tokens). Mention this if the user deploys the image.

## Inputs

| Input | Default | |
|---|---|---|
| `image` | (required) | Image name without registry, lowercase |
| `context` | `.` | Build context |
| `file` | `<context>/Dockerfile` | Dockerfile path |
| `target` | | Multi-stage build target |
| `build-args` | | `NAME=value`, one per line |
| `platforms` | `linux/amd64` | e.g. `linux/amd64,linux/arm64` |
| `push` | `true` | `false` only builds |
| `tags` | branch, pr, semver | `docker/metadata-action` tag rules, one per line |
| `flavor` | `latest=auto` | `docker/metadata-action` flavor |

Outputs: `tags`, `digest` (use them in a later job, e.g. a deploy step, via
`needs.publish.outputs.digest`).

Tags produced by the defaults:

| Trigger | Tags |
|---|---|
| tag `v1.2.3` | `1.2.3`, `1.2`, `1`, `latest` (no `latest` for pre-releases) |
| branch push | `<branch>` |
| pull request | `pr-<number>` |

## When the shared workflow does not fit

It does not cover build secrets (`--secret`), other registries, signing or
SBOM attestation, or running tests inside the build job. If the project needs
one of these, say so and ask before writing a custom workflow, rather than
silently bypassing the shared one. Suggest adding the missing feature to
`GhentCDH/.github` when other projects are likely to need it too.
