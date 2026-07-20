<!--
Inspired by: https://raw.githubusercontent.com/multica-ai/andrej-karpathy-skills/refs/heads/main/CLAUDE.md
-->

# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly before implementing. If uncertain, ask.
- If multiple interpretations exist, list them and ask which — don't pick silently.
- If a simpler approach exists, name it before writing the requested one.
- If something is unclear, stop and name exactly what's confusing.

Ask up front, then execute autonomously against the agreed criteria — don't re-ask mid-task once the goal is clear.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features, config, or flexibility that wasn't asked for.
- No abstractions for single-use code.
- No error handling for scenarios that can't occur.
- If it's 200 lines and could be 50, rewrite it before showing it.

Test: would a senior engineer call this overcomplicated? If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't improve, refactor, or reformat adjacent code that isn't broken.
- Match existing style, even if you'd do it differently.
- Remove imports/variables/functions that YOUR changes made unused.
- Don't delete pre-existing dead code — mention it instead.

Test: every changed line should trace directly to the request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Turn tasks into verifiable goals:

- "Add validation" → write tests for invalid inputs, then make them pass.
- "Fix the bug" → write a test that reproduces it, then make it pass.
- "Refactor X" → confirm tests pass before and after.

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```

## 5. Verify Versions and Known Issues

**Don't trust training data for anything that changes. Check current sources.**

- Before adding or upgrading a dependency, look up the latest stable version and read its release notes for breaking changes.
- Check for known issues, deprecations, and security advisories affecting the version in use.
- For fast-moving or unfamiliar APIs, verify current syntax against official docs — don't assume from memory.
- Don't silently bump versions. Flag outdated or vulnerable pins and let the user decide.
- Prefer the versions already pinned in the project's lockfile/manifest unless asked to change them.
