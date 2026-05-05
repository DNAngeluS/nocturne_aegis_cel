# Nocturne Aegis Cel Candidate Generator v3

This version fixes the CLIP 77-token truncation problem seen in v2.

Main changes:
- Uses StableDiffusionXLPipeline.
- Keeps prompt and prompt_2 under CLIP token limits.
- Uses concise Illustrious/Kohaku-style tags instead of long prose.
- Adds token counting before generation.
- Uses prompt_2 for compact style conditioning.
- Adds compact negative prompts that block sketch, monochrome, lineart-only, and unfinished outputs.
- Uses aspect-aware resolutions.
- Saves PNG images, matching LoRA captions, metadata CSV/JSONL, contact sheet, and a ZIP archive.

Recommended first smoke test:
- NUM_IMAGES_PER_PROMPT = 2
- NUM_INFERENCE_STEPS = 38
- GUIDANCE_SCALE = 7.0
- CLIP_SKIP = 2

If output remains sketchy:
- Increase GUIDANCE_SCALE to 7.5
- Keep negative prompt compact
- Do not use long prose prompts over 77 CLIP tokens
