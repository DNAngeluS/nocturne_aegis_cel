# Nocturne Aegis Cel LoRA Training Pack

This pack is a ready-to-use scaffold for creating the `nacel_v1` style LoRA. It includes:

- base-model recommendation notes
- a 30-image balanced dataset plan
- content-only caption templates
- validation prompts
- Kohya SDXL LoRA config starter
- Diffusers SDXL LoRA command starter
- a seed reference image and caption

## Recommended base model

Researched current Hugging Face options (August 2026) to settle on one canonical
base shared by candidate generation and LoRA training — see
`.agents/lora-training.md` for the full decision record. All three below are
unmerged, checkpoint-native, anime-focused SDXL finetunes trained on tag-style
captions, matching the tag-based prompt architecture already used in `src/`
and this pack.

### Primary recommendation: `OnomaAIResearch/Illustrious-XL-v2.0`

This is now the single base used for **both** candidate generation
(`src/nocturne_aegis_gen.ipynb`, the active notebook — see
`src/CHANGELOG.md`) and LoRA training — no more split between "what generates
candidates" and "what trains the LoRA."

- Onoma ships this specific file as the **untuned base checkpoint**, released
  because it "works as a better merging/training base" than their
  aesthetic-tuned checkpoint — it's a training base by design, not a repurposed
  generation checkpoint.
- License: MIT + CreativeML Open RAIL++ — permissive, no non-commercial
  restriction.
- Native Illustrious tag conditioning — no rework needed for the existing
  `STYLE_*` tag bundles, `prompts/dataset_plan.csv` prose, or the configs in
  `configs/`.
- Ships as a single ~6.94 GB safetensors file, not a Diffusers-format repo.
  Kohya's `sd-scripts` (`configs/kohya_sdxl_lora_config.toml`) loads that
  natively. The Diffusers script (`configs/diffusers_train_command.sh`) needs
  a one-time conversion step first — see the note in that file.

### Alternative 1: `Laxhar/noobai-XL-Vpred-1.1`

Community rankings consistently rate this as the strongest Illustrious-lineage
model for raw tag comprehension and anatomy accuracy (full Danbooru + e621
training corpus). Two real trade-offs before switching to it:

- **License**: `fair-ai-public-license-1.0-sd` explicitly prohibits
  commercialization of the model or derivative products. Only pick this if
  the project stays non-commercial.
- **Architecture**: it's v-prediction, not epsilon-prediction. Adopting it
  means updating the scheduler config (zero-terminal-SNR, rescaled CFG) in
  both the notebook's `apply_scheduler()` helper and the training configs —
  not a drop-in model-ID swap.

### Alternative 2: `cagliostrolab/animagine-xl-4.0` (`-zero` for training)

The most recent large "clean" (non-merge) anime SDXL finetune outside the
Illustrious lineage — 8.4M-image dataset, January 2025 cutoff. Like Illustrious,
it ships a dedicated pretrained `-zero` checkpoint recommended for LoRA
training, separate from the aesthetic-optimized release meant for direct
generation. License is CreativeML Open RAIL++-M (permissive, commercial use
allowed). Trade-off: a structured tag-ordering convention
(`1girl/1boy, character, series, rating, ...`) different from the free-form
Illustrious-style tags already in use here — adopting it means rewriting the
tag bundles, not just swapping a model ID.

**Considered and rejected:** Pony Diffusion V6 XL — its `score_9, score_8_up,
...` quality-tag chain and mixed anime/cartoon/furry training data are a poor
fit for this project's purely-anime, cel-shaded tag grammar; adopting it would
mean redesigning the prompt architecture, not just picking a checkpoint.
Community "daily driver" merges such as `John6666/prefect-illustrious-xl-v3-sdxl`,
`John6666/hassaku-xl-illustrious-v31-sdxl`, and WAI-illustrious-SDXL were
excluded on the same standing principle: they're useful for generating
throwaway candidates, but merges can imprint extra, undocumented style bias
into a LoRA trained on top of them.

## Important limitation

The current pack contains only one seed image. Do not train the final style LoRA from a single image. Generate 80-120 candidates, curate the best 24-30, then train. Single-image training will almost certainly overfit to: long-haired armored woman, sword, violet ruins.

## Folder layout

- `dataset_seed/0001_nocturne_reference.png`: seed reference from the conversation.
- `captions/0001_nocturne_reference.txt`: content-only caption for the seed image.
- `prompts/dataset_plan.csv`: 30 prompt/caption rows for generating a balanced training set.
- `prompts/validation_prompts.txt`: prompts to test whether the LoRA learned style without memorizing content.
- `configs/kohya_sdxl_lora_config.toml`: starter Kohya config.
- `configs/diffusers_train_command.sh`: starter Diffusers training command.
- `tools/audit_sheet.csv`: scoring sheet for deciding keep/reject/revise.

## Captioning rule

Every final caption must begin with:

`nacel_v1,`

Captions must describe only content. Omit style words like anime, cel-shaded, jewel-toned, volumetric, chiaroscuro, glass eyes, metallic luster, ambient occlusion, filigree, and 1/2/3 shadow.

## Training target

- final dataset: 24-30 images
- resolution: 1024 px buckets
- rank/dim: 16 or 32
- alpha: same as rank
- epochs: 8-12
- target steps: 1,500-2,500
- save every epoch and pick best checkpoint by validation grids

## First validation rule

A good style LoRA should make these plain subjects adopt Nocturne Aegis Cel without forcing swords, purple armor, or ruined cities:

- `nacel_v1, a woman in a simple white dress standing in a garden`
- `nacel_v1, an elderly mechanic repairing a small machine in a workshop`
- `nacel_v1, a quiet mountain shrine at night, no people`
- `nacel_v1, a futuristic motorcycle parked under a bridge`
