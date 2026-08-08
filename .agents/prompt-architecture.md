# Prompt Architecture & Notebook Version History

How `Nocturne Aegis Cel` prompting is engineered for SDXL, and why the
candidate-generator notebook has gone through four versions. Read
`style-bible.md` first for *what* the style is; this file is about *how* it
gets fed to the model.

## The six-element architecture (the underlying design)

Before any of the SDXL-specific mechanics below, the project's prompts are
built on a fixed six-element structure from
`.memory/Nocturne_Aegis_Cel_Reference.md` (gitignored — see `local-context.md`).
Leave an element out and the model falls back to its training bias, which is
exactly the generic-anime average the project exists to avoid.

1. **Sub-style anchor** — medium and era, not "anime style". Here: high-end
   digital anime illustration transitioning from 90s cel animation.
2. **Linework descriptor** — tapered sweeping lines *plus* bold structural ink
   contours for hard surfaces; selective cross-hatching.
3. **Color language** — saturated jewel tones, digital gradient maps,
   high-contrast flat color blocking.
4. **Lighting/shading engine** — 1/2/3 shadow system, ambient occlusion,
   chiaroscuro, key/fill/rim.
5. **Atmosphere and mood** — cinematic isolation, psychological tension,
   melancholy.
6. **Technical tags** — specular refraction in eyes, anisotropic metallic
   luster, visible cel-paint texture, subtle grain.

The notebook's `STYLE_*` tag bundles are this structure compressed:
`STYLE_ANATOMY_TAGS` ≈ 1, `STYLE_RENDER_TAGS` ≈ 2+4, `STYLE_MATERIAL_TAGS` ≈
3+6, `STYLE_COMPOSITION_TAGS` ≈ 5. Keep that mapping in mind when editing a
bundle — dropping a tag usually means dropping an element.

A full prose ordering also exists for natural-language-capable image tools
(subject → camera → environment → style core → linework → color → lighting →
materials → mood → quality control → negative). That's the form in
`lora/prompts/dataset_plan.csv`; it is **not** what the current checkpoint
wants.

## The core constraint: CLIP 77-token limit

SDXL's two text encoders each truncate at ~77 tokens per channel. Early
attempts wrote the full style bible as prose directly into the prompt, which
silently got truncated — the model never saw most of the style instructions,
and the failure was invisible unless you counted tokens yourself. Every
notebook version since v1 is essentially a response to this problem.

## SDXL's two prompt channels

SDXL supports a second text-encoder channel (`prompt_2` / `negative_prompt_2`)
in addition to the primary `prompt` / `negative_prompt`. The convention used
here (from v3 onward):

- `prompt`: quality tags + subject/content tags + a short style anchor
  (`STYLE_ANATOMY_TAGS` in v4).
- `prompt_2`: compact global rendering/material/composition rules
  (`STYLE_RENDER_TAGS` + `STYLE_MATERIAL_TAGS` + `STYLE_COMPOSITION_TAGS` in
  v4), only sent when `USE_PROMPT_2 = True`.
- `negative_prompt` / `negative_prompt_2`: split the same way — general
  quality/anatomy blockers on the primary channel, style-drift blockers
  (generic anime, weak shadows, blurry lineart) on the secondary channel.

This lets the full style grammar fit under the token ceiling by splitting it
across two channels instead of cramming it into one.

**Caveat, learned the hard way:** `prompt_2` is not a style-only channel. It
conditions subject semantics too. A real run with genre nouns in `prompt_2`
(`fantasy, science fiction, reflective metal, ...`) turned a `1girl, solo,
portrait` prompt into a mecha — see `generation-runs.md`, Run C. Keep
`prompt_2` restricted to rendering / material / composition vocabulary, and
re-validate any `prompt_2` change against a `USE_PROMPT_2 = False` control at
the same step count before scaling a batch up.

## Notebook version history

As of 2026-08-08 this project retired the one-file-per-version scheme. There
is a single active notebook, **`src/nocturne_aegis_gen.ipynb`**, iterated in
place; `src/CHANGELOG.md` is the running log of changes to it (new entries at
the top, condensed mirror in the notebook's own "Changelog Summary" cell).
The table below is preserved as the compressed history of how the pipeline
got to its current defaults — full recompiled detail lives in
`src/CHANGELOG.md`.

| Version | Status | Scale | Key characteristic | What broke / what it fixed |
|---|---|---|---|---|
| v1 | superseded | 10 prompts × 8 seeds = 80 images | Long prose style-core prompt | Prompt (246 tokens) got silently truncated by CLIP; most style instructions never reached the model. |
| v2 | superseded | 10 × 8 = 80 | Switched to tag-style prompts, added quality/negative tags | Fixed some SDXL issues but leaned too far into generic tag cleanup — still risked weak style steering. |
| v3 | superseded | 10 × 8 = 80 | Split `prompt` / `prompt_2` to protect token budget; added token counting | Protected token length but became light on notebook guidance and **silently trimmed** overflowing prompts, which hides the exact reason a run drifts off-style. Prompt file: `src/prompts_illustrious_v3.json`. |
| v4 (`_definitive`) | superseded | small iteration pass: 3 prompts × 1 seed = 3 images, meant to scale up after validation | Tag-mode default for `Illustrious v0.1`-family checkpoints, **fail-fast** token validation (raises instead of trimming), explicit Colab HF-token handling, optional refiner + upscaler stages | Folded into `nocturne_aegis_gen.ipynb` as the seed for the single ongoing notebook (git history: "Added a refiner + upscaler step", "Redefined the style prompt", "Fixed single model for omuna"). |
| **`nocturne_aegis_gen`** | **current / active** | same as v4 at time of migration: 3 prompts × 1 seed = 3 images | Same pipeline as v4, generic'd output naming (drops the `_v4` suffix from output dir/contact sheet/archive), plus the changelog workflow described above | The notebook to edit for all future generation work. |

**`src/nocturne_aegis_gen.ipynb` is the notebook to edit for generation
work.** v1–v4 are kept as history/reference, not as parallel active
pipelines — don't fork new work from them without a reason.

### Why v4 (and its successor) default to tag-mode, not prose

The notebook's config cell explains: `Illustrious v0.1` (and the v2.0
single-file checkpoint currently loaded) is trained primarily on tag-style
conditioning, and the model card notes it struggles with long natural-language
prompts. The notebook's own history confirms this empirically — prose
steering didn't just underperform, it produced broken output. So it uses
`1girl`, `solo`, `mecha`, `ruined city`-style tags for content
(`content_tags` field in the tag-mode prompt file) rather than the prose
style used in `lora/prompts/dataset_plan.csv`.

If you switch to a more natural-language-capable checkpoint in the future,
the notebook's own next-steps note says to revisit `USE_PROMPT_2 = True` with
richer, caption-like prompting — i.e. move back toward the prose form.

## Prompt files (`src/prompts_illustrious_*.json`)

- `prompts_illustrious_v3.json` — 10-row prose-adjacent set, used by v3.
- `prompts_illustrious_v4_iteration.json` — 3-row set, natural-language
  `content_tags` (e.g. "adult sky pilot, close portrait, cracked helmet held
  near chest...").
- `prompts_illustrious_v4_tag_iteration.json` — 3-row set, pure Illustrious
  tag syntax (e.g. "general, 1girl, solo, portrait, upper body..."). **This is
  the file `PROMPTS_FILE` currently points to** — check the `CONFIG` cell in
  `src/nocturne_aegis_gen.ipynb` before assuming otherwise if you change it.
  (Filename kept its `v4` tag because it's dataset content carried over from
  that notebook, not a marker of the current notebook's version.)

All three enforce the same invariant (asserted in the notebook): every row's
`caption` must start with `nacel_v1,`.

## Current generation defaults (check the `CONFIG` cell for the live values)

- Model: `OnomaAIResearch/Illustrious-XL-v2.0`, loaded via `from_single_file`
  (single safetensors file, not a Diffusers-format repo) — this is also the
  canonical LoRA training base (`lora/README.md` and the LoRA training
  configs were updated to match); see `lora-training.md` for the base-model
  decision record and the alternatives considered.
- Scheduler: `dpmpp_2m_karras` (DPM++ 2M Karras), configurable to `euler_a` or
  `default`.
- Steps: 28, Guidance scale: 6.5, `CLIP_SKIP = None` by default.
- `MAX_TOKENS_PER_CHANNEL = 75`, `FAIL_ON_TOKEN_OVERFLOW = True` — a prompt
  that overflows raises instead of silently truncating. Keep it this way;
  this was a deliberate fix for the v3 failure mode.
- Aspect-aware resolutions: portrait 896×1152, full_body 832×1216, wide
  1216×832, square 1024×1024.
- Optional stages, both off by default: SDXL refiner (`USE_REFINER`) and a 4x
  upscaler (`USE_FINAL_UPSCALER`).

## Onoma's own guidance for the Illustrious family

From the Illustrious-XL model card (local copy: `.memory/onoma_ai/README.md`;
technical report: arXiv:2409.19946). Worth following because it comes from the
people who trained the checkpoint:

- **Sampling:** Euler a, 20-28 steps, CFG 5-7.5. The notebook's 28 steps /
  CFG 6.5 sits inside this; its `dpmpp_2m_karras` default is a deliberate
  departure for aesthetic detail, noted in the CONFIG cell.
- **Quality tags** are a supported, trained vocabulary:
  `worst quality`, `bad quality`, `average quality`, `good quality`,
  `best quality`, `masterpiece`. Prefer these exact strings over invented
  quality filler.
- **"The model does not have any default style. This is intended behavior for
  the base model."** This is the single most important line for this project:
  a base checkpoint with no aesthetic tuning will not volunteer style. All
  style must come from the prompt now, and from the LoRA later. It also
  explains why output reads generic — that is the checkpoint behaving as
  designed, not a prompt bug (see `generation-runs.md`).
- **Don't over-stack composition tags.** Onoma explicitly warns that
  `close-up`, `upside-down`, `cowboy shot` etc. conflict with each other and
  confuse the model. Use one composition tag per prompt (`upper body`,
  `portrait`, `cowboy shot`, `full body`).
- Their example negative prompts are the source of several tags already in
  `NEGATIVE_PROMPT` (`worst quality, comic, multiple views, lowres,
  displeasing, scan artifacts, monochrome, greyscale, jpeg artifacts,
  extra digits, fewer digits`).

## Escalation rule baked into the notebook

The notebook's own "Next Iteration Rules" cell is worth preserving verbatim as
guidance for anyone iterating on this: if images stay incoherent/blob-like
after tuning tags and steps, **stop tuning the prompt** and treat it as a
checkpoint/pipeline problem instead (switch checkpoint or add a refine stage),
not something more prompt-engineering can fix.
