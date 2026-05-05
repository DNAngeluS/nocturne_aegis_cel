# Repository Guidelines

## Project Structure & Module Organization

This repository defines the `Nocturne Aegis Cel` style system and the tooling needed to generate a curated LoRA dataset and then train the LoRA itself. The intended end-to-end workflow is Google Colab first: use Colab to run candidate generation, curate and caption the resulting training images, and then use Colab or equivalent GPU hardware to train the final LoRA.

- `src/nocturne_aegis_candidate_generator_v3.ipynb`: main SDXL candidate generation notebook.
- `requirements.txt`: Python dependencies for generation and training utilities.
- `data/prompts_illustrious_v3.json`: prompt data used by the generator.
- `data/previous/`: archived earlier project packs; treat as reference material, not active source.
- `lora/`: LoRA training pack, including `configs/`, `prompts/`, `captions/`, `dataset_seed/`, and `tools/`.
- `.memory/`: project memory and style-definition documents. Treat these as the canonical source for project intent, style rules, captioning constraints, and the planned LoRA workflow.

Keep generated images, model files, and transient training outputs out of source directories unless they are intentional seed/reference assets.

## Build, Test, and Development Commands

Set up a local environment with:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Preferred workflow: open `src/nocturne_aegis_candidate_generator_v3.ipynb` in Google Colab and execute cells top to bottom. Local Jupyter is acceptable for development, but Colab is the primary target environment for both image generation and final LoRA training.

For a smoke test, use `NUM_IMAGES_PER_PROMPT = 2`, `NUM_INFERENCE_STEPS = 38`, `GUIDANCE_SCALE = 7.0`, and `CLIP_SKIP = 2`.

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

This checkout has no accessible Git history, so no project-specific commit convention can be inferred. Use concise imperative commits, such as `Update LoRA validation prompts` or `Tune candidate generator settings`.

Pull requests should include a summary, affected paths, validation performed, and screenshots/contact sheets when image output changes. Link related issues or experiments, and call out model, seed, and hardware changes that affect reproducibility.

## Security & Configuration Tips

Do not commit Hugging Face tokens, private model credentials, or local absolute paths. Keep large checkpoints and generated training runs outside the repository or in ignored artifact storage.

For Colab-oriented workflows, keep Drive mount points, secrets, and temporary runtime paths configurable and out of committed files.
