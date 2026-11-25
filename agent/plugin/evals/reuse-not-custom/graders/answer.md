---
type: llm
---

Either the agent writes a workflow that calls one of GhentCDH's shared
workflows (`GhentCDH/.github/.github/workflows/ghcr-publish.yaml@v1` or
`dockerhub-publish.yaml@v1`), or it asks the user which registry to publish
to (GHCR or Docker Hub) and says it will use the shared workflow. It does
not write its own docker login, metadata or build-push steps.
