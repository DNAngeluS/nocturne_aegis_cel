# LoRA Dataset & Training Memory

Everything about turning curated candidate images into the `nacel_v1` LoRA.
Read `style-bible.md` for the visual grammar and `prompt-architecture.md` for
how candidates get generated; this file covers curation → captioning →
training.

## Pipeline

1. Generate a broad candidate pool in Colab (`src/nocturne_aegis_gen.ipynb`,
   the active notebook — see `src/CHANGELOG.md` for its iteration history).
2. Audit for style fidelity and reject weak candidates
   (`lora/tools/audit_sheet.csv`).
3. Select the clean training subset — target **24-30 final images**.
4. Write content-only captions prefixed with `nacel_v1,`.
5. Train the LoRA (`lora/configs/`).
6. Validate with `lora/prompts/validation_prompts.txt`.

## Captioning rule (hard requirement)

- Every final caption **must** begin with `nacel_v1,`.
- Captions describe **content only** — subject, pose, setting, objects.
- Never include style words in a caption: `anime`, `cel-shaded`, `jewel-toned`,
  `volumetric`, `chiaroscuro`, `glass eyes`, `metallic luster`, `ambient
  occlusion`, `filigree`, `1/2/3 shadow`. The LoRA should learn the style from
  the pixels, not from a caption shortcut.
- This is enforced by convention/review, not by code — there is no automated
  linter for it. When writing or editing captions, check them against this
  list by hand.

## Dataset plan (`lora/prompts/dataset_plan.csv`)

30 rows, each with `id, category, content_brief, generation_prompt,
negative_prompt, lora_caption`. Categories and counts:

- close portrait: 5 (0001-0005)
- bust: 5 (0006-0010)
- full body: 5 (0011-0015)
- action: 5 (0016-0020)
- wide environment: 5 (0021-0025, two of which are people-free environment
  shots)
- object study: 2 (0026-0027)
- mech study: 1 (0028)
- creature study: 1 (0029)
- vehicle study: 1 (0030)

`generation_prompt` in this file uses the **prose** style-bible form (see
`style-bible.md`); it predates the v4 tag-mode pivot. If you regenerate this
dataset plan from the v4 tag-mode notebook instead, keep the same category
spread and keep `lora_caption` content-only with the `nacel_v1,` prefix.

## Validation prompts (`lora/prompts/validation_prompts.txt`)

Purpose: prove the LoRA learned the *style*, not the seed content. Good
validation prompts are deliberately plain/mundane subjects — a woman in a
white dress, an elderly mechanic, a motorcycle under a bridge, a teapot — that
should still come out in Nocturne Aegis Cel rendering **without** forcing
swords, purple armor, or ruined cities. If validation renders keep defaulting
to armored warriors regardless of prompt content, that's a sign the dataset
collapsed (see the diversity requirement in `style-bible.md`) and the LoRA
overfit to the seed composition.

## Candidate pool sizing and balance targets

Not yet reflected anywhere in the repo's own files, but this is the plan the
dataset was designed around:

- Generate **80-120 candidates**, keep the best **24-30**. The current run
  history is 3 candidates generated, 0 accepted (`generation-runs.md`) — the
  pool phase has effectively not started.
- Selection rule, stated plainly: *only train on images that are both beautiful
  and structurally clean.* One flaw is a reject, not a "maybe".
- **Lighting balance** across the final set — roughly a third each:
  neutral/readable-form lighting, extreme chiaroscuro, backlit rim-light and
  atmospheric. A set that's all chiaroscuro teaches the LoRA "dark", not the
  shadow system.
- Subject diversity is a hard requirement, not a nicety: women, men, and
  androgynous adults; short/long/tied hair and helmets; armored, unarmored,
  cloth-heavy, pilot suits, ceremonial; humans, androids, masked figures,
  creatures, vehicles, weapons; ruins, interiors, skies, temples, cities,
  forests, void backgrounds; calm, walking, combat, seated, profile.
  (Adults only — no minors in the dataset.)

## Audit sheet (`lora/tools/audit_sheet.csv`)

Header only today (no scored rows yet). Columns, each scored 0-3:
`silhouette_proportion`, `face_eyes`, `linework_hierarchy`,
`palette_consistency`, `shadow_lighting`, `material_separation`,
`composition_mood`, `artifact_hygiene`, plus `total`, `recommendation`,
`notes`. Use this rubric — not ad hoc judgment — when auditing a generation
batch for the training subset.

**Acceptance threshold: 21/24.** The CSV doesn't state it; it comes from the
upstream Custom GPT's audit mode (`custom-gpt.md`), which is where the rubric
originated. Score, total, then accept only ≥ 21 — that's the mechanism that
enforces "beautiful *and* structurally clean" instead of letting a pretty
image with melted hands through.

Explicit reject triggers (any one is disqualifying): malformed hands or extra
fingers; unreadable face or eyes; distorted anatomy; melted armor or fused
objects; text/logo/watermark/signature; excessive visual noise; generic-anime
drift; photorealistic drift; overfitted purple-warrior sameness; background
detail overpowering the subject; weak linework hierarchy; no clear ambient
occlusion or contact shadows.

## Seed reference (`lora/dataset_seed/`)

- `0001_nocturne_reference.png` + `0001_nocturne_reference.txt`.
- The seed image is a full-body armored woman with violet/black armor, sword,
  ruined futuristic city, moon — i.e. **exactly** the composition the project
  explicitly warns against over-representing. `lora/README.md` is explicit:
  do not train the final style LoRA from this single image; it will overfit
  to "long-haired armored woman, sword, violet ruins." Treat it as one seed
  data point among 24-30, not a template.

## Base model

**`OnomaAIResearch/Illustrious-XL-v2.0` — the single canonical base for both
candidate generation and LoRA training.** Settled; not an open question.
`lora/README.md`, both `lora/configs/*`, and the notebook's `CONFIG` cell all
point at it.

Why it fits: Onoma ships it as the *untuned* training base, it speaks the
free-form Illustrious tag conditioning the `STYLE_*` bundles already use, and
its license is permissive (MIT + CreativeML Open RAIL++), so `nacel_v1` comes
out unencumbered.

One operational caveat: it ships as a single ~6.94 GB safetensors file, not a
Diffusers-format repo. Kohya `sd-scripts` loads it natively; the plain
Diffusers training script needs a one-time `from_single_file` →
`save_pretrained()` conversion first (documented inline in
`lora/configs/diffusers_train_command.sh`).

Alternatives were surveyed once (NoobAI v-pred, Animagine XL 4.0-zero, Pony V6)
and none justified the switch — each would mean reworking the scheduler config
or rewriting the tag bundles, and some carry `fair-ai-public-license-1.0-sd`,
which would force the LoRA open-source and bar closed-source monetization.
Don't relitigate without a concrete reason; if you ever do swap the base, check
the license first and update `lora/configs/*`, `lora/README.md`, and the
notebook `CONFIG` comment together.

## Training config summary

**Kohya (`lora/configs/kohya_sdxl_lora_config.toml`):**
resolution 1024 (bucketed 512-1536), `network_dim`/`network_alpha` = 32,
batch size 2 × grad-accum 2, 10 epochs (save every epoch), lr 1e-4
(unet) / 1e-5 (text encoder), cosine schedule, 100 warmup steps, AdamW8bit,
bf16, `clip_skip = 2`, seed `23111990`.

**Diffusers (`lora/configs/diffusers_train_command.sh`):**
`train_text_to_image_lora_sdxl.py`, resolution 1024, `--random_flip`, batch
size 1 × grad-accum 4, max 2000 steps (checkpoint every 250), rank 32, lr
1e-4 cosine with 100 warmup steps, bf16, same seed `23111990`.

**Recommended production target (from `lora/README.md`):** 24-30 images,
1024px buckets, rank/dim 16 or 32, alpha = rank, 8-12 epochs, 1,500-2,500
total steps, save every epoch and pick the best checkpoint by validation
grids (not just the last epoch).

Both starter configs use paths like `./dataset_final` and `./output` that
must be updated before running — they are scaffolds, not ready-to-run as-is.
