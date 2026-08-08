# Local (Gitignored) Context — `.memory/`, `data/`, `output/`

**Status correction (2026-08-08):** earlier `.agents/` notes claimed `.memory/`
and `data/` "do not exist in this checkout." That was wrong — they exist on the
author's machine and are simply `.gitignore`d, so they are invisible to a fresh
clone and to any agent without local filesystem access. They have now been read
and distilled into the tracked `.agents/` files.

Treat this file as the map of what lives outside version control, so agents
know what to ask for rather than re-deriving it.

## Rule for these directories

- `.agents/` (tracked) is canonical for agents. `.memory/` is the **authoring
  source** those distillations came from.
- **Never copy secrets, tokens, or personal data out of these folders into
  tracked files.** Distill rules and decisions, not raw credentials.
- Never `git add` these paths. They are ignored deliberately (`.gitignore`
  lines for `data/`, `.memory`, `output/`, `.env`).

## `.memory/` — the author's design documents

Written mostly by/with ChatGPT while designing the style. Prose design docs, no
code, no credentials.

| File | What it is | Where it now lives in tracked memory |
|---|---|---|
| `Nocturne_Aegis_Cel_Reference.md` | The long-form research report: deconstruction of five artistic influences, the six-element prompt architecture, ControlNet/IP-Adapter photo→anime workflow, LoRA hyperparameter reasoning | `style-bible.md` (influences), `prompt-architecture.md` (six elements), `img2img-workflow.md`, `lora-training.md` |
| `Nocturne_Aegis_Plan.md` | The master plan: style naming, style bible, prompt v2 templates, LoRA dataset strategy, the full Custom GPT configuration | `style-bible.md`, `lora-training.md`, `custom-gpt.md` |
| `Nocturne_Aegis_Cel_Style_Bible.md` | The knowledge file uploaded to the Custom GPT; identical to the style-bible block embedded in `Nocturne_Aegis_Plan.md` §13 | `style-bible.md` |
| `Nocturne_Aegis_Mastert_Prompt.md` (sic) | The Custom GPT's Instructions field, verbatim | `custom-gpt.md` |
| `onoma_ai/README.md` | Copy of the Illustrious-XL v0.1 Hugging Face model card | `prompt-architecture.md` (sampling guidance), `lora-training.md` (licensing) |
| `onoma_ai/Illustrious Technical Report.pdf`, `arXiv-2409.19946v1.tar.gz` | The Illustrious paper (arXiv:2409.19946) and its source | reference only |

Two docs still worth reading in full if you are redesigning the style rather
than iterating on it: `Nocturne_Aegis_Cel_Reference.md` (the *why* behind every
mechanical tag) and `Nocturne_Aegis_Plan.md` §7 (the style-strength knobs).

## `data/` — archived earlier project packs and scratch files

Historical, superseded. Nothing here is on the active path.

- `previous/*.zip` — the ChatGPT-produced project packs that `src/v1`-`v3` and
  `lora/` originally came from.
- `prompts.json`, `prompts_illustrious_optimized.json`,
  `prompts_illustrorious_optimized.json` (typo'd duplicate),
  `prompts_illustrious_v3.json` — earlier prompt sets. Live prompt files are
  the `src/prompts_illustrious_*.json` copies.
- `chatGPT-Progress.md` — Colab setup walkthrough plus early iteration notes;
  already distilled into `prompt-architecture.md` and `src/CHANGELOG.md`.
- `test.py` — unrelated scratch script (Stable Diffusion 2, cheese-moon prompt).
  Not project code. **See the security note below before touching it.**
- `VOID_Diffusion_*.ipynb` / `.py` — a third-party NSFW SD 2.1 Colab notebook,
  unrelated to this project and not part of its pipeline. Nocturne Aegis Cel
  itself is an SFW illustration-style project; don't pull anything from that
  notebook into the pipeline or treat it as project convention.

## `output/` — real local generation runs

The only empirical evidence of how this pipeline actually behaves. Analyzed in
`generation-runs.md`, which is the file to read; the raw artifacts are:

- `images/` + `metadata.csv` / `metadata.jsonl` — the 2026-05-05 07:44 UTC run
  (3 images, prose-hybrid prompt, 38 steps / CFG 7.0 / CLIP_SKIP 2).
- `run-1.contact_sheet_v4.jpg` + `run-1.output_archive_v4.zip` — 24 steps,
  CFG 6.0, no CLIP skip, `prompt_2` disabled.
- `run-2.contact_sheet_v4.jpg` + `run-2.output_archive_v4.zip` — 32 steps,
  CFG 6.0, `prompt_2` enabled with genre tags.

Note the notebook writes to `outputs/` (plural) while these landed in
`output/` (singular); both are gitignored.

## Security findings (2026-08-08 audit of these folders)

1. **A real-looking Hugging Face token is hardcoded in `data/test.py:64`**, in a
   commented-out `use_auth_token="hf_…"` argument. It was **never committed** —
   verified with `git log --all -S` on the token string and by confirming
   `data/`, `.memory/`, `output/`, and `.env` have never appeared in any tracked
   tree (only `.env.example` has). It is still a plaintext credential on disk
   inside the repo directory, one `git add -f` away from exposure.
   **Recommended: revoke it at https://huggingface.co/settings/tokens and delete
   the line.** Do not reproduce the token value in any tracked file, commit
   message, or issue.
2. `.env` holds a real `HUGGINGFACEHUB_API_TOKEN`. Correctly gitignored;
   `.env.example` is the tracked template. Leave it alone.
3. Nothing else scanned as credential-like: no private keys, no personal data,
   and no absolute user paths in `.memory/`. The design docs are safe to
   distill into tracked memory, which is what `.agents/` now does.
4. When adding to `.agents/`, keep the same bar: repo-relative paths only, no
   tokens, no machine-specific paths, no third-party content dumps.
