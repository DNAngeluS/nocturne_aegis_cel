# Nocturne Aegis Cel

This repository is building an original anime illustration style pipeline called `Nocturne Aegis Cel`. The end goal is to use Google Colab to generate a curated training-image dataset for the style, then train a LoRA from that dataset, and finally validate the LoRA against a fixed prompt set.

## Project Goal

The target workflow is:

1. Define and preserve the `Nocturne Aegis Cel` style grammar.
2. Generate many candidate images in Google Colab.
3. Audit and reject weak candidates.
4. Caption the accepted images with content-only captions prefixed by `nacel_v1,`.
5. Train the final LoRA.
6. Validate the trained LoRA with style-consistency prompts.

This is not just a generic SDXL image notebook. It is a style-construction and LoRA-preparation pipeline.

## Core Identity

- Style name: `Nocturne Aegis Cel`
- Future LoRA trigger token: `nacel_v1`
- Visual direction: 1990s cel-animation skeleton plus modern volumetric digital finish
- Prompting rule: use technical visual language, not artist-name invocations

The style memory and prompt rules live in `.memory/` and should be treated as canonical project context.

## Main Components

- `src/nocturne_aegis_candidate_generator_v3.ipynb`: main SDXL candidate generation notebook.
- `data/prompts_illustrious_v3.json`: prompt source used by the generator.
- `lora/`: LoRA training pack, configs, prompts, captions, and tooling.
- `.memory/`: project memory, style bible, plan, and master prompting documents.

## Candidate Generator v3

The current notebook version fixes the CLIP 77-token truncation problem seen in v2.

Main changes:
- Uses StableDiffusionXLPipeline.
- Keeps prompt and prompt_2 under CLIP token limits.
- Uses concise Illustrious/Kohaku-style tags instead of long prose.
- Adds token counting before generation.
- Uses prompt_2 for compact style conditioning.
- Adds compact negative prompts that block sketch, monochrome, lineart-only, and unfinished outputs.
- Uses aspect-aware resolutions.
- Saves PNG images, matching LoRA captions, metadata CSV/JSONL, contact sheet, and a ZIP archive.

## Recommended Workflow

Preferred environment: Google Colab.

Before loading gated or frequently requested Hugging Face models in Colab, set `HF_TOKEN` in Colab Secrets or as an environment variable so downloads are authenticated and less likely to hit anonymous rate limits.

Recommended first smoke test:
- NUM_IMAGES_PER_PROMPT = 2
- NUM_INFERENCE_STEPS = 38
- GUIDANCE_SCALE = 7.0
- CLIP_SKIP = 2

If output remains sketchy:
- Increase GUIDANCE_SCALE to 7.5
- Keep negative prompt compact
- Do not use long prose prompts over 77 CLIP tokens

## LoRA Dataset Rules

- Final captions must begin with `nacel_v1,`.
- Captions should describe content only.
- Do not include style words like anime, cel-shaded, volumetric, chiaroscuro, glass eyes, or metallic luster in captions.
- Do not let the dataset collapse into one repeated subject or composition.
- Reject images with malformed hands, distorted anatomy, unreadable faces, fused objects, text, logos, or generic-anime drift.

## Development Notes

Local execution is fine for editing and small tests, but the intended production path is Colab-based generation and LoRA training. Keep checkpoints, generated outputs, secrets, and Drive-specific paths out of committed source files.
