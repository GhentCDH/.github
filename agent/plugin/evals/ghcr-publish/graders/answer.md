---
type: llm
---

The final answer says the workflow uses GhentCDH's shared GHCR workflow and
that pushing a version tag (such as `v1.2.3`) publishes the image to
ghcr.io. It does not say the workflow needs a secret added to the
repository to run. (Mentioning a personal access token for pulling a private
image on a server is fine: that is not a secret the workflow needs.)
