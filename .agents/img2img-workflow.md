# Photo → Nocturne Aegis Cel (img2img) Workflow

A second, currently **unimplemented** half of the project. The research doc in
`.memory/Nocturne_Aegis_Cel_Reference.md` and the plan in
`.memory/Nocturne_Aegis_Plan.md` §6 both treat photo-to-anime conversion as a
first-class goal alongside text-to-image candidate generation, but nothing in
`src/` or `lora/` implements it yet — the notebooks are txt2img only.

Recorded here so the design isn't lost, and so nobody re-researches it.

## The core claim

Prompting alone cannot convert a photograph into this style — txt2img just
generates an unrelated character. Structural control and style injection have
to be separate mechanisms:

- **ControlNet** holds the photograph's pose, silhouette, and spatial layout.
- **IP-Adapter** injects the style, bypassing the text encoder entirely (it
  routes CLIP-vision features straight into the U-Net cross-attention layers).
- The **text prompt** supplies detail vocabulary.

This needs a node-based runtime (ComfyUI) or A1111 — not the plain Diffusers
`StableDiffusionXLPipeline` the current notebook uses. Adding it means a new
notebook or a new pipeline path, not a config flag.

## What to preserve vs. what to replace

Preserve from the input: identity, pose, expression, camera angle, major
silhouette, spatial layout, composition.
Replace: rendering, linework, lighting, color language, material behavior,
atmosphere.
Never: invent a new pose or composition unless explicitly asked.

## ControlNet selection

| Preprocessor | Function | Use for | Weight |
|---|---|---|---|
| SoftEdge (HED/PiDiNet) | soft boundary + volume | human silhouettes, while leaving room for stylized hair/cloth — avoids the traced-photo look | 0.5-0.8 |
| Lineart (Anime) | photo → anime lineart | the main driver of drawn (not photoreal) output | 0.6-0.9 |
| Depth | Z-axis separation | stopping background bleed into the foreground under heavy stylization | 0.3-0.5 |
| Canny | hard edges | locking mechanical shapes / architecture; too rigid for faces alone | 0.4-0.6 |

SoftEdge + Depth, or Lineart Anime + Depth, are the recommended pairs. Canny
alone produces rigid traced-looking output because it forces lines wherever the
photo had shadows.

## IP-Adapter

Weight **0.4-0.6** for style transfer. At 1.0 it overwhelms both the text
prompt and ControlNet and simply reproduces the reference image's composition.
In IP-Adapter Plus (ComfyUI), route the reference into `image_style` and leave
`image_composition` empty so only palette/shading/line character transfer.

The style references fed to it should be the project's own best txt2img
outputs — which is a dependency worth stating plainly: **the img2img path can't
start until the txt2img path produces images that actually hold the style**
(see `generation-runs.md` — it doesn't yet).

## Denoise / control presets

| Goal | Denoise | ControlNet | IP-Adapter |
|---|---|---|---|
| Preserve likeness strongly | 0.25-0.40 | SoftEdge 0.6-0.8, Depth 0.3-0.5 | 0.35-0.50 |
| Balanced conversion | 0.40-0.55 | Lineart Anime 0.6-0.8, Depth 0.3-0.5 | 0.40-0.60 |
| Heavy stylization | 0.55-0.70 | Lineart Anime 0.7-0.9, SoftEdge 0.5-0.7 | 0.50-0.65 |

## Relationship to the LoRA

These two paths converge: once `nacel_v1` exists, it can be loaded alongside
ControlNet, and the IP-Adapter's job shrinks or disappears because the style
lives in the weights. The img2img rig is the bridge for the period *before* the
LoRA exists — and also a way to generate golden-dataset candidates with
guaranteed compositional variety, which is exactly the diversity problem
`style-bible.md` flags.
