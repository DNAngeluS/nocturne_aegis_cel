# Notebook Fix & Improvement Tracking

Working checklist for `src/nocturne_aegis_gen.ipynb`, generated from the
notebook review on 2026-08-08. Two groups: **Fixes** (concrete, low-risk,
scoped to what's already in the notebook) and **Architecture Improvements**
(bigger, discuss-before-building changes).

## How to use this file

- Check an item off (`- [ ]` → `- [x]`) only once it's actually done, not
  when it's started.
- When you finish an item, add a dated entry to `src/CHANGELOG.md` (and
  update the notebook's own "Changelog Summary" cell to match) if the change
  touches `nocturne_aegis_gen.ipynb` — see the local/Colab parity rule in
  `AGENTS.md` for what else might need updating alongside it (prompt JSON,
  `lora/prompts/*`, `lora/configs/*`, `.agents/*.md`).
- Work through these one at a time rather than batching — that's the point
  of tracking them here instead of doing them all in one pass.
- "Repo clone / Colab bootstrap" was raised during the review but is
  intentionally **not** on this list yet — needs more context on the
  intended Colab launch flow before it's scoped into a task.

---

## Fixes

- [ ] **1. Add missing nbformat cell IDs**
  `nbformat.validate()` warns that the two intro markdown cells (positions 0
  and 1 in `nocturne_aegis_gen.ipynb`) lack unique `id` fields — an nbformat
  4.5+ requirement, inherited from `v4_definitive` and earlier notebooks.
  Future nbformat versions will hard-error instead of warn. Add unique ids
  to these two cells so the notebook validates cleanly with no warnings.

- [ ] **2. Relax the hardcoded 3-prompt assert**
  Cell `id=0350551b` asserts `len(prompt_rows) == 3`, which locks the
  notebook to exactly 3 prompt rows and blocks any run-size flexibility.
  This is the root blocker behind Architecture Improvement A (configurable
  image count) below — needs to become a soft check (or be removed) so
  prompt/row count can be driven by `PROMPTS_FILE`/config instead of a
  hardcoded literal.

- [ ] **3. Improve error handling for relative-path assumptions**
  `PROMPTS_FILE` and `OUTPUT_ROOT` are relative paths that assume
  CWD = repo root; opening the notebook standalone in a fresh Colab runtime
  currently fails at the prompt-file-not-found check with no explanation of
  why. The full bootstrap/git-clone solution is intentionally deferred (see
  the note above — needs more context on the intended Colab launch flow).
  Scope this narrower for now: fail with a clearer error message that names
  the CWD assumption explicitly, so the failure is self-explanatory even
  before the bootstrap-cell question is settled.

- [ ] **4. Replace deprecated `datetime.utcnow()`**
  Used in the generation-loop metadata cell (`id=9a5e7f8e`); deprecated
  since Python 3.12. Switch to `datetime.now(timezone.utc)` before it starts
  emitting warnings on newer local Python versions, per the local/Colab
  parity rule in `AGENTS.md`.

- [ ] **5. Stop silently swallowing exceptions**
  Both `except Exception: pass` blocks — `enable_vae_tiling()` in the
  model-load cell (`id=b20fe46d`) and the Colab-secret `HF_TOKEN` lookup in
  the setup cell (`id=f19dfa77`) — hide any error, not just "unsupported."
  This contradicts the notebook's own fail-fast philosophy established for
  prompt token overflow (`FAIL_ON_TOKEN_OVERFLOW`). At minimum, print what
  got caught instead of silently passing.

- [ ] **6. Add explicit IPython `display` import**
  The generation-loop cell (`id=9a5e7f8e`) calls `display(...)` relying on
  the IPython-injected global with no import. Works interactively in
  Jupyter/Colab but is fragile if this logic is ever run headless
  (`nbconvert --execute`, papermill). Add
  `from IPython.display import display` explicitly.

- [ ] **7. Pin notebook's pip-installed package versions + print them**
  The pip-install cell upgrades `diffusers`/`transformers`/`accelerate`/
  `safetensors`/`huggingface_hub` with `-U` and no ceiling, risking silent
  behavior drift between runs now that this notebook is iterated
  indefinitely instead of frozen per version. Pin to known-good versions and
  print installed versions in the `CONFIG` cell's output, so a future "why
  did this suddenly behave differently" is diagnosable from the run log.

- [ ] **8. Clean up leftover v3/v4-relative prose**
  Cells like "Configuration" (`id=24eada6a`) and "Load Model"
  (`id=e9e267f9`) still say things like "This notebook *now* defaults
  to..." and "Key changes from the *previous* broken setup..." — phrasing
  written when the reader had just come from the v3/v4 notebooks. Now that
  history lives in `src/CHANGELOG.md`, rewrite these cells to stand on
  their own without assuming that context.

- [ ] **9. Avoid rebuilding the scheduler on every image**
  `apply_scheduler()` runs inside `call_pipe()` (cell `id=35af3faf`) on
  every single image generation call, even when `ENABLE_SWEEP=False` and
  the scheduler is constant for the whole run. Harmless but wasteful —
  hoist the call outside the per-image loop when the scheduler isn't
  changing between plans.

---

## Architecture Improvements

- [ ] **A. Make the number of images generated per run configurable**
  Replace the notebook's hardcoded "3 prompts x 1 seed" iteration mode with
  a configurable run size (e.g. a setting alongside the existing
  `NUM_IMAGES_PER_PROMPT` that controls how many prompt rows / total images
  a run produces), so during this testing phase of the overall project
  quality the number of generated images can be dialed up or down from the
  `CONFIG` cell without editing code or hitting the hardcoded-3 assert
  (Fix #2). Default should stay small (matches today's 3-image smoke test),
  but the same notebook should be able to scale toward larger batches (up
  to the 80-120 image production pool `lora/README.md`'s pipeline depends
  on) purely via config — no forking to a different notebook file.

- [ ] **B. Extract shared tag bundles/helpers into a single importable source of truth**
  `STYLE_*` tag bundles and helper functions (`build_positive_prompt`,
  token counting, etc.) currently exist only as notebook cells in
  `nocturne_aegis_gen.ipynb`, and are separately duplicated in prose form in
  `lora/prompts/dataset_plan.csv` and `.agents/style-bible.md`. Move them
  into a shared JSON/YAML data file or small importable Python module that
  both the notebook and any future dataset tooling load, cutting the "keep
  3 files in sync by hand" burden already documented in
  `.agents/repo-notes.md`, and making the pure-Python logic (token
  counting, prompt assembly) unit-testable without a GPU.

- [ ] **C. Pin `diffusers`/`transformers`/`accelerate` versions in `requirements.txt` too**
  Companion to Fix #7 — extend version pinning to `requirements.txt` (local
  venv) so local and Colab environments stay reproducible and in parity as
  this notebook keeps evolving indefinitely instead of being frozen per
  version, per the local/Colab parity rule in `AGENTS.md`.

- [ ] **E. Add a `schema_version` field to generation metadata (CSV/JSONL)**
  `metadata.csv`/`metadata.jsonl` columns are implicitly defined by
  whatever keys happen to be in the dict at generation time; if the
  notebook's logged fields change later, older metadata files carry no
  marker distinguishing schema versions. Add a `schema_version` field to
  each metadata row so the `lora/tools/audit_sheet.csv` workflow and any
  future tooling can detect when the notebook's output schema changed
  between runs.

- [ ] **F. Decide the dual-changelog design: mirror vs. link**
  Discuss and settle whether the notebook's "Changelog Summary" cell should
  keep mirroring a condensed copy of `src/CHANGELOG.md` (current design —
  real drift risk since nothing enforces the two stay in sync) or should
  simply link to `CHANGELOG.md` instead. No content change until this is
  decided; the task is to have the discussion and then apply the chosen
  approach consistently.
