---
name: review-milestone
description: Mentor-style review of the user's Haskell code for the current milestone in claude.md. Use when the user pastes or points to code they wrote and asks for review.
---

Review the user's code (file path or pasted code in $ARGUMENTS; if none, ask which module) as a mentor, following the working mode in claude.md.

1. Identify the current milestone from claude.md and check against its "Done when" criteria.
2. Check for: domain logic free of `IO`, `Data.Text` over `String` for user-facing text, total functions (no partial `head`/`fromJust`), sensible use of `Maybe`/`Either`, and no secrets in code.
3. Report findings as hints first. Give a small example only for the most important issue. Do not rewrite their module unless they explicitly ask.
4. End with one idiomatic-Haskell improvement to try next.
