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

Primary recommendation: `OnomaAIResearch/Illustrious-xl-early-release-v0` or the closest official Illustrious XL v1.x checkpoint available in your trainer.

Reason: Nocturne Aegis Cel depends on anime-native SDXL behavior, strong linework, glass-eye rendering, dramatic cel shading, and promptable fantasy/mechanical content. Illustrious XL is a canonical anime SDXL-family base and is less risky than training on a heavily merged checkpoint.

Alternative for stronger modern anime output: `Laxhar/noobai-XL-1.1`. Use it if your target inference ecosystem is NoobAI/Illustrious merges and you accept its license/content-tag constraints.

Avoid training the first official LoRA directly on merged checkpoints such as `John6666/prefect-illustrious-xl-v3-sdxl` or `John6666/hassaku-xl-illustrious-v31-sdxl`; they are useful for generating candidates, but merges can imprint extra style bias into the LoRA.

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
