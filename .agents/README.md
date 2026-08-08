# `.agents/` — Repository Memory

This directory holds durable, git-tracked memory about `Nocturne Aegis Cel` that
is too detailed for the root `AGENTS.md` but too important to re-derive from
scratch every session. Read the relevant file(s) before non-trivial work; update
them when you learn something new or change a project convention.

Root `AGENTS.md` is the short contributor-facing guide (structure, commands,
conventions). `CLAUDE.md` is Claude Code's own launchpad and points here.
This directory is the deep reference the other two link out to.

Note: `AGENTS.md` and `README.md` both mention a `.memory/` directory as the
"canonical" style/plan source. That directory does not exist in this checkout
(it is `.gitignore`d and was likely a local-only folder for the original
author). Treat **this** `.agents/` directory as the actual, tracked memory
store going forward — see `repo-notes.md` for the full discrepancy list.

## Files

- `style-bible.md` — the `Nocturne Aegis Cel` visual grammar: identity, anatomy,
  rendering, palette, composition, and what to avoid. Read before touching any
  prompt, tag bundle, or caption.
- `prompt-architecture.md` — how prompting is engineered for SDXL (dual text
  encoder channels, CLIP token limits, tag-mode vs. prose-mode), plus the
  version history of the candidate-generator notebooks (v1 → v4).
- `lora-training.md` — dataset rules, captioning rules, the 30-row dataset plan,
  audit workflow, and the LoRA training configs (Kohya + Diffusers).
- `repo-notes.md` — reality-check of the repo structure against what
  `README.md`/`AGENTS.md` claim, environment/dependency quirks, and the
  local-vs-Colab parity rule for making changes.

## Updating this directory

- Keep entries factual and specific to this repo — not generic Diffusers/LoRA
  tutorials.
- When a notebook, prompt file, or config changes in a way that affects the
  style grammar, captioning rule, or recommended defaults, update the matching
  `.agents/` file in the same change.
- Prefer editing these files over letting knowledge live only in commit
  messages or chat history.
