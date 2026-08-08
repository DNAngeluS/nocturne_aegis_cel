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

The style memory and prompt rules live in `.agents/` (tracked) — start at `.agents/README.md`. A local, gitignored `.memory/` folder holds the original design documents those were distilled from; it is not part of a clone.

## Main Components

- `src/nocturne_aegis_gen.ipynb`: the active SDXL candidate generation notebook. Iterated in place — see `src/CHANGELOG.md` for its history, including the superseded `v1`-`v4` notebooks kept in `src/` as reference.
- `src/prompts_illustrious_v4_tag_iteration.json`: prompt source used by the generator.
- `lora/`: LoRA training pack, configs, prompts, captions, and tooling.
- `.agents/`: repository memory — style bible, prompt architecture, LoRA workflow, run findings.

## Candidate Generator

Base model: `OnomaAIResearch/Illustrious-XL-v2.0` (MIT + CreativeML Open RAIL++), used for both candidate generation and LoRA training.

What the notebook does:
- Uses `StableDiffusionXLPipeline`, loading the checkpoint from a single safetensors file.
- Uses concise Illustrious-style tags rather than long prose.
- Splits the style grammar across `prompt` and `prompt_2` to stay under the CLIP 77-token limit, counting tokens and failing fast on overflow.
- Applies compact negative prompts blocking sketch, monochrome, lineart-only, and unfinished output.
- Uses aspect-aware resolutions (portrait / full body / wide / square).
- Saves PNGs, matching LoRA captions, metadata CSV/JSONL, a contact sheet, and a ZIP archive.
- Has optional refiner and 4x upscaler stages, both off by default.

## Recommended Workflow

Preferred environment: Google Colab.

Before loading gated or frequently requested Hugging Face models in Colab, set `HF_TOKEN` in Colab Secrets or as an environment variable so downloads are authenticated and less likely to hit anonymous rate limits.

Recommended first smoke test (the notebook's defaults):
- NUM_IMAGES_PER_PROMPT = 1
- NUM_INFERENCE_STEPS = 28
- GUIDANCE_SCALE = 6.5
- CLIP_SKIP = None

If output drifts off-style:
- Keep prompts in tag form and the negative prompt compact.
- Never exceed 77 CLIP tokens per channel.
- Keep genre/subject nouns out of `prompt_2` — it steers subject, not just style.
- If images stay incoherent after tag and step tuning, stop tuning prompts and treat it as a pipeline problem (refiner stage, or a different checkpoint).

## LoRA Dataset Rules

- Final captions must begin with `nacel_v1,`.
- Captions should describe content only.
- Do not include style words like anime, cel-shaded, volumetric, chiaroscuro, glass eyes, or metallic luster in captions.
- Do not let the dataset collapse into one repeated subject or composition.
- Reject images with malformed hands, distorted anatomy, unreadable faces, fused objects, text, logos, or generic-anime drift.

## Development Notes

Local execution is fine for editing and small tests, but the intended production path is Colab-based generation and LoRA training. Keep checkpoints, generated outputs, secrets, and Drive-specific paths out of committed source files.
