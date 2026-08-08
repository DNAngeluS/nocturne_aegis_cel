# "Nocturne Aegis Style Forge" — the upstream Custom GPT

Context that explains where this repo's prompts, dataset plan, and captions
actually come from. Most of the content in `lora/prompts/dataset_plan.csv`,
`lora/captions/`, and the early `src/prompts_illustrious_*.json` files was
authored by a ChatGPT Custom GPT, not written by hand in this repo.

The GPT's full Instructions field lives in
`.memory/Nocturne_Aegis_Mastert_Prompt.md` (gitignored — see
`local-context.md`); its setup is specified in `.memory/Nocturne_Aegis_Plan.md`
§10-12. This file records what an agent working in the repo needs to know
about it.

## Why it matters here

1. **It is the style's enforcement layer outside the code.** If you change a
   style rule in `.agents/` or `lora/` but not in the GPT, the next batch of
   prompts the user generates will silently reintroduce the old rule. The
   parity rule in `repo-notes.md` effectively extends to it — flag GPT-side
   drift to the user, since only they can edit it.
2. **It explains stylistic quirks in the data.** The prose `generation_prompt`
   column in `dataset_plan.csv` is the GPT's Mode A template verbatim — prose
   rather than Illustrious tags, and containing the literal string
   `Nocturne Aegis Cel`. It was written for ChatGPT/DALL·E-class image tools,
   which take long natural language, not for the Illustrious SDXL checkpoint
   this repo generates with. Don't feed it straight to the notebook.
3. **The original reference image was made by ChatGPT's image tool, not by
   Illustrious.** So `lora/dataset_seed/0001_nocturne_reference.png` sets a
   fidelity bar the local pipeline hasn't matched yet, and isn't evidence about
   what the Illustrious path can reach.

## Configuration summary

- Name: `Nocturne Aegis Style Forge`. Capabilities: image generation on, code
  interpreter on, web search off by default (to avoid style drift), actions off.
- Knowledge files: the research PDF (`Crafting Unique Anime Art Style.pdf`,
  local copy of the same content: `.memory/Nocturne_Aegis_Cel_Reference.md`)
  and `Nocturne_Aegis_Cel_Style_Bible.md`.
- Custom GPTs don't use saved memory or prior chats, so all rules are pasted
  into Instructions + knowledge files rather than accumulated in conversation.

## Its five modes

| Mode | Trigger | Output |
|---|---|---|
| A — text-to-image | new image from text | prompt, negative prompt, settings, style checklist |
| B — image-to-image | uploaded image / transform request | preservation brief, transform prompt, negative, img2img settings, ControlNet guidance (see `img2img-workflow.md`) |
| C — LoRA dataset | "generate many prompts" | objective, shot matrix, prompt list, caption list, rejection criteria, coverage checklist |
| D — captioning | "caption these" | `nacel_v1,` + content-only, as filename→caption pairs |
| E — style audit | uploaded generations | the 8×0-3 rubric, keep/revise/reject |

Mode E is the origin of `lora/tools/audit_sheet.csv` — same eight axes, same
0-3 scale. The GPT adds the acceptance threshold the CSV doesn't state:
**only candidates scoring ≥ 21/24 are accepted for training** (recorded in
`lora-training.md`).

## Rules it enforces that also bind work in this repo

These are the same invariants already in `style-bible.md` and
`lora-training.md`; listed here so it's clear they are enforced in both places
and must be changed in both:

- No artist names in final prompts — translate influence into mechanics.
- Captions: `nacel_v1,` prefix, content only, no style words, no quality tags.
- Don't repeat purple-armored-female-warrior compositions; vary gender, age
  (adults only), costume, camera distance, lighting, setting, and subject class
  (human / mech / creature / vehicle / object / environment).
- Generate more candidates than needed; select only structurally clean images.

## Style-strength knobs (defined by the GPT, not yet in any repo file)

Worth knowing about, because prompts arriving from the GPT may have been
generated under a specific setting:

- `STYLE_STRENGTH`: subtle / balanced / strong
- `ORNAMENT_DENSITY`: low / medium / high
- `MECHANICAL_DENSITY`: none / light / medium / heavy
- `SHOT_TYPE`: close portrait / bust / cowboy shot / full body / action
  diagonal / wide environmental / object-material study
- `PALETTE_VARIANT`: see the variants table in `style-bible.md`
