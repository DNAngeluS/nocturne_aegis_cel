# Nocturne Aegis Cel Candidate Generator — Changelog

Running changelog for the candidate-generation notebook. Starting with
`src/nocturne_aegis_gen.ipynb`, this project stops creating a new
`_v5`/`_v6`/... notebook file for every iteration. There is one active
notebook; changes to it get logged here instead.

## How to use this file

- Add new entries **at the top**, under a dated heading.
- One entry per meaningful change (a prompt/style/config/pipeline decision),
  not per keystroke or cell tweak.
- Say what changed, **why**, and flag any follow-up needed elsewhere
  (`PROMPTS_FILE`, `lora/prompts/*`, `lora/configs/*`, `.agents/*.md`) — see
  the local/Colab parity rule in `AGENTS.md` / `.agents/repo-notes.md`.
- After adding an entry here, mirror a condensed version into the
  **"Changelog Summary"** cell at the end of `src/nocturne_aegis_gen.ipynb`
  so the notebook is self-explanatory even if someone never opens this file.

## Unreleased

_(nothing yet — add new entries above this line as they land)_

## 2026-08-08 — Consolidated into `nocturne_aegis_gen.ipynb`; retired the file-per-version scheme

- Created `src/nocturne_aegis_gen.ipynb`, seeded from the working state of
  `src/nocturne_aegis_candidate_generator_v4_definitive.ipynb`. This is now
  **the** active notebook — all future generation-pipeline work happens here.
- `v1`-`v4` notebook files remain in `src/` as historical reference (not
  deleted, not to be forked from without reason). Their history is recompiled
  below so future sessions don't have to re-read four notebooks to understand
  why the pipeline looks the way it does.
- Generic'd version-specific naming inherited from v4: output directory
  (`outputs/nocturne_aegis_candidates_v4` → `outputs/nocturne_aegis_candidates`),
  contact sheet (`contact_sheet_v4.jpg` → `contact_sheet.jpg`), archive
  (`output_archive_v4.zip` → `output_archive.zip`). `PROMPTS_FILE` still
  points at `src/prompts_illustrious_v4_tag_iteration.json` — that file
  wasn't renamed, it's dataset content, not a notebook version marker.
- Same day, separately: reconciled the base-model discrepancy between this
  pipeline and LoRA training onto one canonical checkpoint
  (`OnomaAIResearch/Illustrious-XL-v2.0`) — see `lora/README.md` and
  `.agents/lora-training.md` for that decision record.

---

## History recompiled from the retired v1 → v4 notebooks

Preserved here so the reasoning behind current defaults (tag-mode prompting,
dual-channel SDXL prompts, fail-fast token validation) doesn't get lost now
that the version-per-file trail is retired. See `.agents/prompt-architecture.md`
for the deeper technical writeup this summarizes.

### v4 "definitive" (`nocturne_aegis_candidate_generator_v4_definitive.ipynb`)

- Switched to **tag-mode prompting by default** for `Illustrious v0.1`-family
  checkpoints — the previous hybrid natural-language steering wasn't just
  weak, it produced broken output, per the Illustrious model card's own
  guidance that v0.1 struggles with long natural-language prompts.
- Replaced v3's silent prompt trimming with **fail-fast token validation**
  (`FAIL_ON_TOKEN_OVERFLOW = True`) so an overflowing prompt channel raises
  instead of quietly losing style instructions.
- Added explicit Colab `HF_TOKEN` handling (env var → `HUGGINGFACEHUB_API_TOKEN`
  → Colab Secret fallback) and clearer inline Colab documentation.
- Added optional SDXL refiner and 4x-upscaler stages (off by default).
- Defaulted to a small **3 prompts × 1 seed = 3 image** iteration run instead
  of a full 80-image batch, on the reasoning that a broken 3-image pass means
  an 80-image batch will only scale the failure.
- Mid-version, the loaded checkpoint changed to
  `OnomaAIResearch/Illustrious-XL-v2.0` (single-file safetensors) — this
  later became the canonical base for LoRA training too (2026-08-08).

### v3 (`nocturne_aegis_candidate_generator_v3.ipynb`)

- Fixed the **CLIP 77-token truncation** problem: split prompting across
  SDXL's `prompt`/`prompt_2` channels and added token counting so prompts
  could be checked against the limit.
- Regression: became light on notebook guidance and **silently trimmed**
  prompts that overflowed the token budget — a failure mode invisible unless
  you went looking for it. This directly motivated v4's fail-fast validation.
- Prompt file: `src/prompts_illustrious_v3.json`. Default batch: 10 prompts ×
  8 seeds = 80 candidates.

### v2 (`nocturne_aegis_candidate_generator_v2.ipynb`)

- Switched from a long prose prompt to **tag-style prompts**.
- Added strong quality tags and a negative prompt blocking
  sketch/monochrome/grayscale/rough/unfinished output.
- Fixed several SDXL pipeline issues present in v1, but still leaned heavily
  on generic tag cleanup and risked weak style steering.

### v1 (`nocturne_aegis_candidate_generator_v1.ipynb`)

- The original candidate generator: 10 prompts × 8 images = 80 candidates,
  base model `OnomaAIResearch/Illustrious-xl-early-release-v0`.
- Used a **long prose "style core"** paragraph appended to every content
  prompt. It got silently truncated by CLIP's ~77-token limit, so most of the
  style instructions never reached the model — **this is the root failure
  every later version (v2 → v4) worked to fix**, whether by tag compression,
  channel splitting, or fail-fast validation.
- Established the output convention still used today: PNG images + sidecar
  `.txt` LoRA captions + metadata CSV/JSONL + contact sheet + ZIP archive.

## Related repo-level changes (not notebook-specific, recorded for context)

- **2026-08-08** — Resolved the base-model split between candidate generation
  and LoRA training. Canonical base is now `OnomaAIResearch/Illustrious-XL-v2.0`
  for both. Two alternatives (`Laxhar/noobai-XL-Vpred-1.1`,
  `cagliostrolab/animagine-xl-4.0`) researched and documented with trade-offs
  in `lora/README.md` / `.agents/lora-training.md`.
- **2026-08-08** — Added `.agents/` repository memory, root `CLAUDE.md`
  launchpad, and the local/Colab parity rule in `AGENTS.md`.
