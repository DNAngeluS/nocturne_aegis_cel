# Repo Reality Check & Environment Notes

`README.md` and `AGENTS.md` describe an intended/idealized structure. Some of
it doesn't match this checkout. This file records the actual state so agents
don't waste time looking for things that aren't there, and don't recreate
things that were deliberately gitignored.

## Structure claims that don't match this checkout

- **`.memory/` — resolved (2026-08-08).** Earlier versions of this file said
  it "does not exist." **That was wrong.** It exists on the author's machine
  and is `.gitignore`d, so it is absent from a fresh clone and invisible to any
  agent without local filesystem access. It has now been read and distilled
  into `.agents/`. Its contents and the mapping to tracked files are in
  `local-context.md`. Practical rule unchanged: **`.agents/` is canonical for
  agents** (it's the part that survives a clone), `.memory/` is the authoring
  source behind it. The `README.md`/`AGENTS.md` wording has been corrected to
  say "gitignored, may exist locally" rather than "not present".
- **`data/` — resolved (2026-08-08).** Same correction: it exists locally and
  is gitignored, and it does contain `prompts_illustrious_v3.json` and
  `previous/` (the archived ChatGPT project packs) as `AGENTS.md` originally
  described. But those are **history**, not the active path — the live prompt
  JSONs are the `src/` copies (`src/prompts_illustrious_v3.json`,
  `src/prompts_illustrious_v4_iteration.json`,
  `src/prompts_illustrious_v4_tag_iteration.json`). Use the `src/` paths.
  Inventory in `local-context.md`, including a plaintext-credential finding in
  `data/test.py` that needs the user's attention.
- **`output/`** — also gitignored and present locally: three real generation
  runs (images, metadata CSV/JSONL, contact sheets, archives). This is the
  project's only empirical evidence and it is analyzed in `generation-runs.md`.
  Note the notebook writes to `outputs/` (plural) while these landed in
  `output/` (singular); both are ignored, so neither is at risk of commit.
- **Main notebook version — resolved.** `README.md` and `AGENTS.md` used to
  point at `nocturne_aegis_candidate_generator_v3.ipynb` (later `v4`) as the
  "main" notebook; both were updated (2026-08-08) to point at
  `src/nocturne_aegis_gen.ipynb`, the current active notebook. See
  `src/CHANGELOG.md` for why the file-per-version scheme was retired in favor
  of one notebook iterated in place plus a changelog. `v1`-`v4` remain in
  `src/` as historical reference only.
- **`.codex`** — empty file at repo root, no documented purpose. Leave as-is
  unless the user explains what it's for.

The `.memory/` mismatch above is still open — that one hasn't been fixed in
`README.md`/`AGENTS.md` yet. If you do a cleanup pass on it, it's reasonable
to update the remaining `.memory/` references to point at `.agents/` instead
— but confirm with the user before rewriting their existing docs wholesale,
since `.memory/` may still exist on their own
machine outside this checkout.

## Local vs. Colab — the parity rule

The project is meant to work **both** as local Python (venv + Jupyter) and as
Google Colab, and Colab is the primary/production target. The notebooks
already handle this by guarding Colab-only calls:

```python
try:
    from google.colab import userdata
    HF_TOKEN = userdata.get("HF_TOKEN")
except Exception:
    HF_TOKEN = None
```

Keep using this guarded-import pattern for anything Colab-specific (Drive
mount, Colab secrets, `!pip install` magics) so the same notebook cell runs
unmodified in a local Jupyter kernel.

**When you change style tags, prompt content, captioning rules, or generation
defaults, treat it as one logical change that must land in every place that
representation exists, not just the notebook cell you happened to edit.**
Concretely, check all of:

- the active notebook (`src/nocturne_aegis_gen.ipynb`) — and a matching entry
  in `src/CHANGELOG.md` (plus its condensed mirror in the notebook's own
  "Changelog Summary" cell) for any change worth remembering
- whichever prompt JSON file `PROMPTS_FILE` points to in that notebook's
  `CONFIG` cell (currently `src/prompts_illustrious_v4_tag_iteration.json`)
- `lora/prompts/dataset_plan.csv` and `lora/prompts/validation_prompts.txt` if
  the change affects the LoRA dataset or captioning rule
- `lora/configs/kohya_sdxl_lora_config.toml` and
  `lora/configs/diffusers_train_command.sh` if it affects training defaults
- the relevant `.agents/*.md` file, so the memory doesn't go stale

A change that only touches the notebook and leaves the JSON/CSV/config files
describing the old behavior is an incomplete change here, not a finished one.

## Environment / dependencies

- `requirements.txt`: `diffusers>=0.30.0`, `transformers>=4.43.0`,
  `accelerate>=0.33.0`, `safetensors`, `pillow`, `pandas`, `tqdm`. This is the
  local-venv install list; the v4 notebook's first cell pins/upgrades a
  slightly different set for Colab specifically (see next point).
- v4 notebook Colab pip cell deliberately pins `pandas==2.2.2` and
  `"Pillow<12.0"` before upgrading `diffusers`/`transformers`/`accelerate` —
  the comment explains newer pandas 3.x / Pillow 12.x versions conflict with
  Colab's preinstalled runtime. Don't "helpfully" bump these without checking
  Colab's current base image, since the whole point of the pin is Colab
  compatibility.
- `HF_TOKEN` resolution order (in both `.env.example` and the v4 notebook):
  `HF_TOKEN` env var → `HUGGINGFACEHUB_API_TOKEN` env var → Colab Secret named
  `HF_TOKEN`. Never commit a real token; `.env` is gitignored,
  `.env.example` is the template.
- No automated test suite exists. Validation is manual: smoke-test generation
  runs, inspect token-count reports, contact sheets, and metadata
  CSV/JSONL, plus the LoRA audit sheet / validation prompts for
  training-side changes.

## Commit style observed in history

Short, plain-imperative subjects, no strict convention (e.g. "Redefined the
style prompt", "Added a refiner + upscaler step", "Fixed single model for
omuna"). Match that tone rather than inventing a Conventional Commits format
the repo doesn't use.
