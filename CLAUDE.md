# CLAUDE.md

Guidance for Claude Code working in this repository. This file is a compact
launchpad — the deep reference material lives in `AGENTS.md` (contributor
guide) and `.agents/` (repository memory). Read those before non-trivial
work; don't duplicate their content from memory.

## What this project is

`Nocturne Aegis Cel` — an original anime illustration style built with
Diffusers/SDXL. The pipeline: define the style grammar → generate candidate
images in Google Colab → curate/caption them → train a `nacel_v1` LoRA →
validate the LoRA holds the style without memorizing the seed content.
Style name: `Nocturne Aegis Cel`. LoRA trigger token: `nacel_v1`.

This is **not** a generic SDXL notebook repo — it's a style-construction and
LoRA-preparation pipeline. Most "code" lives inside Jupyter notebooks in
`src/`, plus supporting configs/prompts/captions under `lora/`.

## Read before you touch anything style/prompt/training-related

1. `AGENTS.md` — structure, commands, conventions, PR/commit expectations.
2. `.agents/README.md` — index of the memory files below.
3. `.agents/style-bible.md` — the actual visual grammar (identity, anatomy,
   linework, palette, composition, what to avoid). Every prompt/tag/caption
   change must stay consistent with this.
4. `.agents/prompt-architecture.md` — how SDXL prompting is engineered here
   (dual text-encoder channels, CLIP 77-token limit, tag-mode vs. prose, and
   the full v1→v4 notebook version history/rationale).
5. `.agents/lora-training.md` — dataset plan, captioning rule, audit
   workflow, training configs, and the base-model decision record (three
   options researched, one chosen as canonical for both candidate generation
   and LoRA training).
6. `.agents/repo-notes.md` — where the repo's actual structure diverges from
   what `README.md`/`AGENTS.md` describe (e.g. `.memory/` and `data/` don't
   exist in a fresh checkout), environment quirks, and the local/Colab parity
   rule.

## The one rule that matters most here

**Local Python and Google Colab must stay in parity, and every representation
of a style/prompt/caption/config change must be updated together.** If you
edit the style grammar, tags, captions, or generation/training defaults in
one place (a notebook cell, a prompt JSON, `lora/prompts/*.csv`, or
`lora/configs/*`), find and update the other places it's duplicated. See
`.agents/repo-notes.md` for the concrete checklist — don't treat a
notebook-only edit as done.

## Orientation

- `src/nocturne_aegis_gen.ipynb` — **the active notebook**, iterated in place.
  There is no more one-file-per-version scheme: log changes in
  `src/CHANGELOG.md` (new entry at the top) and mirror a condensed version
  into the notebook's own "Changelog Summary" cell at the end. `v1`-`v4` in
  the same directory are superseded history; don't fork new work from them
  without reason (full rationale in `.agents/prompt-architecture.md` and
  `src/CHANGELOG.md`).
- `src/prompts_illustrious_v4_tag_iteration.json` — the prompt file the
  notebook currently loads (check its `CONFIG` cell's `PROMPTS_FILE` before
  assuming this is still current; the filename kept its `v4` tag because it's
  dataset content, not a notebook version marker).
- `lora/` — training pack: `configs/` (Kohya + Diffusers starters),
  `prompts/` (`dataset_plan.csv`, `validation_prompts.txt`), `captions/`,
  `dataset_seed/` (single seed image — do not treat as a template to repeat),
  `tools/audit_sheet.csv` (curation rubric).
- `requirements.txt` — local venv deps. The notebook pins slightly different
  Colab-specific versions in its first cell; that's intentional, see
  `.agents/repo-notes.md`.
- `.env.example` — `HF_TOKEN` / `HUGGINGFACEHUB_API_TOKEN` template. Never
  commit a real token.

## Working conventions

- No automated test suite. Validate with a small generation smoke test
  (`NUM_IMAGES_PER_PROMPT = 2`, `NUM_INFERENCE_STEPS = 38`,
  `GUIDANCE_SCALE = 7.0`, `CLIP_SKIP = 2` per `AGENTS.md`) rather than
  claiming a change works untested.
- Never put style words (`anime`, `cel-shaded`, `glass eyes`, etc.) in final
  LoRA captions — captions are content-only and must start with `nacel_v1,`.
- Never use the literal string `Nocturne Aegis Cel` inside a *generation*
  prompt before the LoRA exists — the base checkpoint doesn't know that
  token; use the mechanical tag/prose grammar instead.
- Don't collapse prompt/dataset work into repeated purple-armored
  female-warrior compositions — preserve the subject-type spread documented
  in `.agents/style-bible.md`.
- Commit style is short, plain-imperative subjects (e.g. "Redefined the style
  prompt") — no enforced Conventional Commits format.
- Keep secrets, checkpoints, and generated outputs out of committed files;
  respect `.gitignore` (`data/`, `outputs/`, `.env`, model weight extensions).
