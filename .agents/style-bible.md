# Nocturne Aegis Cel — Style Bible

Canonical visual grammar for the `Nocturne Aegis Cel` style. This is the source
of truth for any prompt, tag bundle, or style description written anywhere in
the repo. It is compiled from `lora/prompts/dataset_plan.csv` (prose form) and
`src/nocturne_aegis_gen.ipynb` (tag-bundle form)
— the two representations currently in the repo. Keep both in sync with this
file when the style evolves.

## Identity

- Style name: `Nocturne Aegis Cel`
- Future LoRA trigger token: `nacel_v1`
- One-line description: an original high-end digital anime illustration style
  built on a **1990s cel-animation skeleton** with a **modern volumetric
  digital-painting finish**.
- Prompting rule: describe the style **mechanically** (linework, shading,
  palette, anatomy). Never invoke real artist names. Never put the literal
  string `Nocturne Aegis Cel` inside a *generation* prompt before the LoRA
  exists — the base checkpoint doesn't know that token and it will just add
  noise. Use the tag/prose grammar below instead.

## Anatomy & Face

- Elongated, elegant proportions "where applicable" (not forced on every
  subject — see composition variety rule below).
- Sharp, geometric face design; angular jaw.
- Subtle melancholic expression.
- Glass-like, geometric eyes.
- Soft skin rendering (contrasted against hard-surface materials).

## Linework & Shading

- Tapered, sweeping linework.
- Bold, hard-surface ink contours.
- Cel shading with **layered 1/2/3 shadows** (not flat single-shadow cel).
- Deep ambient occlusion.
- Extreme chiaroscuro.
- Crisp rim light.
- Volumetric painting finish over the cel base — this is what separates the
  style from generic flat-cel anime.

## Palette & Materials

- Jewel tones: blackened indigo, violet, magenta, sapphire.
- Accents: antique gold, pale silver.
- Material separation is a hard requirement: matte cloth vs. iridescent
  metal vs. burnished chrome (with micro-scratches) vs. glass must all read as
  visually distinct surfaces in the same image.

## Composition

- Cinematic isolation of the subject.
- Clear, readable silhouette.
- Ornamental restraint — detail should be hierarchical, not uniform noise.
- Arc composition; hair framing; cable framing; energy arcs as recurring
  compositional devices.
- Controlled detail hierarchy (foreground detail > background detail).

## Diversity requirement (do not collapse the dataset)

`lora/README.md` and `AGENTS.md` both call this out explicitly: **do not let
every image become a purple-armored female warrior with a sword in ruins.**
The single seed reference image (`lora/dataset_seed/0001_nocturne_reference.png`)
*is* exactly that composition — it is a seed/reference only, not a template to
repeat. The dataset plan (`lora/prompts/dataset_plan.csv`) deliberately spans:

- close portraits (armored, unarmored, android, scholar)
- bust shots
- full-body figures
- action poses
- wide environments with **no people**
- object studies (sword, helmet)
- a mech study, a creature study, a vehicle study

When adding new prompts/candidates, preserve this spread across subject type,
gender presentation, armored vs. unarmored, and human vs. mech vs. environment
vs. object.

## Negative space — what breaks the style

Consistently blocked across prompt files and captions:

- generic anime / generic modern anime / bland moe face
- chibi, round childish proportions
- plastic skin, doll face, 3D-render look
- painterly mush, flat lighting, muddy colors
- blurry lineart, uniform line weight (the tapered/hierarchical linework is
  a core identity marker — uniform weight defeats it)
- messy ornamental noise
- bad anatomy, bad/malformed hands, extra or fewer digits, fused objects
- monochrome/greyscale, sketch-like or unfinished output
- text, logo, watermark, signature

## Two grammar representations in this repo

1. **Prose form** (`lora/prompts/dataset_plan.csv`, `generation_prompt` /
   `lora_caption` columns): a full paragraph appended to a content brief,
   written for natural-language-capable checkpoints. This is the style
   described in human-readable form and is the best single reference if you
   need to explain the style to someone.
2. **Tag-bundle form** (`src/nocturne_aegis_gen.ipynb`,
   `QUALITY_TAGS` / `STYLE_ANATOMY_TAGS` / `STYLE_RENDER_TAGS` /
   `STYLE_MATERIAL_TAGS` / `STYLE_COMPOSITION_TAGS`): the same grammar
   compressed into short comma-separated tags for `Illustrious v0.1`-family
   checkpoints, which respond better to tags than prose (see
   `prompt-architecture.md`). This is the form actually sent to the model in
   the current (v4) notebook.

If you change the style grammar, update **both** representations, plus the
LoRA caption negative list in `lora/prompts/dataset_plan.csv`.

## Captioning — separate from generation prompting

Final LoRA captions are **not** style prompts. See `lora-training.md` for the
full rule: captions start with `nacel_v1,` and describe content only — no
style words at all. The LoRA is meant to *learn* the style from the images;
spelling it out in captions would teach the model to associate style words
with the token instead of the visual pattern itself.
