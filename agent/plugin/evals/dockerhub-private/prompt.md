---
tags: [dockerhub]
runs: 3
max_turns: 12
allowed_tools: [Skill, Read, Glob, Grep, Bash, Write]
---

This is a private repo. Create a build workflow that pushes our image to
Docker Hub when we tag a version, and builds it on pull requests.
