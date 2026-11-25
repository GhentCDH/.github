---
tags: [ghcr]
runs: 3
max_turns: 12
allowed_tools: [Skill, Read, Glob, Grep, Bash, Write]
---

Add a GitHub Actions workflow that builds our Docker image and publishes it
to GHCR whenever we tag a release.
