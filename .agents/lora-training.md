# LoRA Dataset & Training Memory

Everything about turning curated candidate images into the `nacel_v1` LoRA.
Read `style-bible.md` for the visual grammar and `prompt-architecture.md` for
how candidates get generated; this file covers curation → captioning →
training.

## Pipeline

1. Generate a broad candidate pool in Colab (`src/nocturne_aegis_candidate_generator_v4_definitive.ipynb`).
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

## Audit sheet (`lora/tools/audit_sheet.csv`)

Header only today (no scored rows yet). Columns, each scored 0-3:
`silhouette_proportion`, `face_eyes`, `linework_hierarchy`,
`palette_consistency`, `shadow_lighting`, `material_separation`,
`composition_mood`, `artifact_hygiene`, plus `total`, `recommendation`,
`notes`. Use this rubric — not ad hoc judgment — when auditing a generation
batch for the training subset.

## Seed reference (`lora/dataset_seed/`)

- `0001_nocturne_reference.png` + `0001_nocturne_reference.txt`.
- The seed image is a full-body armored woman with violet/black armor, sword,
  ruined futuristic city, moon — i.e. **exactly** the composition the project
  explicitly warns against over-representing. `lora/README.md` is explicit:
  do not train the final style LoRA from this single image; it will overfit
  to "long-haired armored woman, sword, violet ruins." Treat it as one seed
  data point among 24-30, not a template.

## Base model — unresolved discrepancy, don't silently pick a side

Two different recommendations currently exist in the repo and have **not**
been reconciled:

- `lora/README.md`, `lora/configs/kohya_sdxl_lora_config.toml`, and
  `lora/configs/diffusers_train_command.sh` all point to
  `OnomaAIResearch/Illustrious-xl-early-release-v0` as the LoRA training base,
  with reasoning: it's a canonical, un-merged anime SDXL base, safer than
  training on a heavily merged checkpoint. They also name
  `Laxhar/noobai-XL-1.1` as an alternative, and explicitly warn against
  training directly on merges like `John6666/prefect-illustrious-xl-v3-sdxl`.
- The v4 candidate-generation notebook was recently changed (commit "Fixed
  single model for omuna") to load `OnomaAIResearch/Illustrious-XL-v2.0` via
  `from_single_file` — a different release than `early-release-v0`.

This may be intentional (v2.0 for candidate generation, early-release-v0 for
the actual LoRA base training run are different jobs), but it has not been
written down as a deliberate decision anywhere. **If you touch base-model
choice, either keep candidate-generation and LoRA-training aligned, or add a
note here explaining why they're intentionally different.** Don't quietly
"fix" one to match the other without checking with the user first.

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
