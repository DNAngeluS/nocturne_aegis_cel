# `.agents/` — Repository Memory

This directory holds durable, git-tracked memory about `Nocturne Aegis Cel` that
is too detailed for the root `AGENTS.md` but too important to re-derive from
scratch every session. Read the relevant file(s) before non-trivial work; update
them when you learn something new or change a project convention.

Root `AGENTS.md` is the short contributor-facing guide (structure, commands,
conventions). `CLAUDE.md` is Claude Code's own launchpad and points here.
This directory is the deep reference the other two link out to.

Note: `.memory/` and `data/` exist on the author's machine but are
`.gitignore`d, so a fresh clone won't have them. Their contents have been
distilled into the files below — `local-context.md` maps what lives where.
Treat **this** `.agents/` directory as the canonical memory store, since it's
the part that survives a clone.

## Files

- `style-bible.md` — the `Nocturne Aegis Cel` visual grammar: identity, anatomy,
  rendering, palette variants, composition, and what to avoid. Read before
  touching any prompt, tag bundle, or caption.
- `prompt-architecture.md` — how prompting is engineered for SDXL (the
  six-element architecture, dual text-encoder channels, CLIP token limits,
  tag-mode vs. prose-mode), Onoma's own guidance for the checkpoint, and the
  notebook version history.
- `lora-training.md` — dataset rules and balance targets, captioning rules, the
  30-row dataset plan, audit rubric and acceptance threshold, base model, and
  the training configs (Kohya + Diffusers).
- `generation-runs.md` — what real runs have and haven't achieved so far, and
  the settings not worth repeating. Short by design.
- `img2img-workflow.md` — the designed-but-unimplemented photo→style conversion
  path (ControlNet + IP-Adapter).
- `custom-gpt.md` — the upstream ChatGPT "Style Forge" that authored much of the
  prompt/caption data, and the rules it enforces outside this repo.
- `local-context.md` — map of the gitignored local folders (`.memory/`, `data/`,
  `output/`), plus security notes on what must never be copied into tracked
  files.
- `repo-notes.md` — reality-check of the repo structure against what
  `README.md`/`AGENTS.md` claim, environment/dependency quirks, and the
  local-vs-Colab parity rule for making changes.

## Tone

This project is early. Prefer recording what is currently true and what to do
next over narrating superseded attempts — prune stale material instead of
layering around it.

## Updating this directory

- Keep entries factual and specific to this repo — not generic Diffusers/LoRA
  tutorials.
- When a notebook, prompt file, or config changes in a way that affects the
  style grammar, captioning rule, or recommended defaults, update the matching
  `.agents/` file in the same change.
- Prefer editing these files over letting knowledge live only in commit
  messages or chat history.
