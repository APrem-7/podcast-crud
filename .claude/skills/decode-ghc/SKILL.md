---
name: decode-ghc
description: Explain a GHC or cabal error the user pasted, escalating from hint to example to fix. Use when the user shares a compiler error.
---

Help the user understand the GHC/cabal error in $ARGUMENTS (or in the conversation). Follow the escalation order from claude.md:

1. Hint: say in plain words what GHC is complaining about and where to look (expected vs actual type, missing instance, scope, etc.). Stop here unless they ask for more.
2. Small example: a minimal, unrelated snippet showing the same mistake and its fix.
3. Worked solution: the corrected version of their code, only when they ask or have tried steps 1-2.

Explain any type-level concept the error relies on (e.g. rigid type variables, missing instances) briefly, since this is a learning project.
