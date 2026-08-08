# Repository Guidelines

## Project Structure & Module Organization

This repository defines the `Nocturne Aegis Cel` style system and the tooling needed to generate a curated LoRA dataset and then train the LoRA itself. The intended end-to-end workflow is Google Colab first: use Colab to run candidate generation, curate and caption the resulting training images, and then use Colab or equivalent GPU hardware to train the final LoRA.

- `src/nocturne_aegis_gen.ipynb`: the active SDXL candidate generation notebook, iterated in place. `src/CHANGELOG.md` is the running log of changes to it (and recompiles the history of the superseded `v1`-`v4` notebooks also kept in `src/`).
- `requirements.txt`: Python dependencies for generation and training utilities.
- `src/prompts_illustrious_v4_tag_iteration.json`: prompt data used by the generator.
- `data/`: gitignored archive of superseded prompt sets and earlier project packs. Present on the author's machine, absent from a fresh clone — don't assume it exists, and don't source live prompts from it (see `.agents/local-context.md`).
- `lora/`: LoRA training pack, including `configs/`, `prompts/`, `captions/`, `dataset_seed/`, and `tools/`.
- `.memory/`: the author's local design documents (style bible, plan, research report, Custom GPT instructions). Gitignored, so absent from a fresh clone; its content has been distilled into `.agents/` — see `.agents/local-context.md` for the mapping.
- `output/`: gitignored local generation runs. Findings worth keeping are summarized in `.agents/generation-runs.md`.
- `.agents/`: the tracked repository memory, and the canonical source for style rules, prompting technique, and LoRA workflow. `README.md` there indexes it: `style-bible.md`, `prompt-architecture.md`, `lora-training.md`, `generation-runs.md`, `img2img-workflow.md`, `custom-gpt.md`, `local-context.md`, `repo-notes.md`. Read before non-trivial changes to prompts, style tags, captions, or training configs.

Keep generated images, model files, and transient training outputs out of source directories unless they are intentional seed/reference assets.

## Agent Memory & Local/Colab Parity

This repo targets both local Python execution and Google Colab, and Colab is
the primary/production environment. Notebooks guard Colab-only calls (Drive
mount, Colab Secrets) behind `try/except google.colab` imports so the same
cells run locally too — follow that pattern for new Colab-specific code.

When you change style tags, prompt content, captioning rules, or generation
defaults, update every place that representation lives, not just the file you
started in: the active notebook, its `PROMPTS_FILE` JSON, `lora/prompts/*`,
and `lora/configs/*` as applicable. See `.agents/repo-notes.md` for the full
checklist. The candidate-generation notebook and the LoRA training configs now
share one canonical base model (`OnomaAIResearch/Illustrious-XL-v2.0`) — see
`.agents/lora-training.md` for that decision and the alternatives considered
before changing it again.

## Build, Test, and Development Commands

Set up a local environment with:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Preferred workflow: open `src/nocturne_aegis_gen.ipynb` in Google Colab and execute cells top to bottom. Local Jupyter is acceptable for development, but Colab is the primary target environment for both image generation and final LoRA training.

For a smoke test, use `NUM_IMAGES_PER_PROMPT = 1-2`, `NUM_INFERENCE_STEPS = 24-28`, `GUIDANCE_SCALE = 6.0-6.5`, and `CLIP_SKIP = None` — the notebook's current defaults, and inside Onoma's recommended range for this checkpoint. (An older 38 / 7.0 / CLIP_SKIP 2 recommendation predates the current base model and produced unusable output; see `.agents/generation-runs.md`.)

LoRA training starters live in `lora/configs/`:

```bash
bash lora/configs/diffusers_train_command.sh
```

Review and adapt paths, model names, Colab storage mounts, and hardware settings before launching training.

Recommended production sequence:
1. Generate a broad candidate pool in Colab.
2. Audit for style fidelity and artifact rejection.
3. Select the clean training subset.
4. Write content-only captions prefixed with `nacel_v1,`.
5. Train the LoRA from the curated dataset.
6. Validate with `lora/prompts/validation_prompts.txt`.

## Coding Style & Naming Conventions

Use `UPPER_SNAKE_CASE` for user-tuned generation settings and `snake_case` for local helper values. Keep prompt and caption files UTF-8 text. Dataset assets should use stable numeric prefixes, for example `0001_nocturne_reference.txt`, so image/caption pairs sort together.

Final LoRA captions must begin with `nacel_v1,` and should describe content only. Do not add style terms such as anime, cel-shaded, glass eyes, metallic luster, or chiaroscuro to final captions.

Preserve the project’s core style identity in all prompt and dataset work:
- Style name: `Nocturne Aegis Cel`
- LoRA trigger token: `nacel_v1`
- Avoid artist-name prompting in final prompts.
- Avoid collapsing the dataset into repeated purple-armored female-warrior compositions.

## Testing Guidelines

There is no automated test suite. Validate changes with a small generation smoke test before larger runs. For prompt or caption changes, inspect token counts, metadata CSV/JSONL, contact sheets, and output PNGs. For LoRA dataset changes, use `lora/tools/audit_sheet.csv` and run `lora/prompts/validation_prompts.txt`.

When changing notebook or prompt logic, prefer validation in the same environment the project is targeting for production, which is Google Colab.

## Commit & Pull Request Guidelines

Commit history uses short, plain-imperative subjects with no strict convention (e.g. "Redefined the style prompt", "Added a refiner + upscaler step"). Match that rather than introducing Conventional Commits. Examples: `Update LoRA validation prompts`, `Tune candidate generator settings`.

Pull requests should include a summary, affected paths, validation performed, and screenshots/contact sheets when image output changes. Link related issues or experiments, and call out model, seed, and hardware changes that affect reproducibility.

## Security & Configuration Tips

Do not commit Hugging Face tokens, private model credentials, or local absolute paths. Keep large checkpoints and generated training runs outside the repository or in ignored artifact storage. `.env` (real token) and `.env.example` (template) are the only intended homes for credentials — never hardcode a token in a script or notebook cell, even commented out.

For Colab-oriented workflows, keep Drive mount points, secrets, and temporary runtime paths configurable and out of committed files.
