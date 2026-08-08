# Generation Runs — What We Know So Far

The project is very early. A handful of exploratory runs exist in the
(gitignored) `output/` directory; none of them produced anything that will be
kept, and no candidate has entered the dataset yet. This file keeps only the
lessons that still change what you'd do next on
`OnomaAIResearch/Illustrious-XL-v2.0` — not a post-mortem of discarded work.

Baseline for everything below: the 3 prompts in
`src/prompts_illustrious_v4_tag_iteration.json` (portrait pilot / full-body
masked knight / winged mech) at seeds 251505-253505.

## What held up

- **Tag-mode content control works.** At 24 steps, CFG 6.0, no CLIP skip, the
  three prompts rendered as the three intended subjects, cleanly composed, with
  intact anatomy. Content steering is not the problem.
- **The style grammar isn't reaching the image.** That same output reads as
  competent generic anime — warm amber/teal grading rather than the jewel
  palette, soft shading rather than layered 1/2/3 cel shadows, no tapered-vs-bold
  linework hierarchy. This is the actual open problem, and it's consistent with
  Onoma's own statement that the base checkpoint has no default style by design
  (`prompt-architecture.md`).

## Two settings to avoid repeating

- **`CLIP_SKIP = 2` on this checkpoint** co-occurred with complete collapse —
  smeared shapes, no subject at all. The notebook's `CLIP_SKIP = None` default
  is correct; don't "restore" 2 without evidence. (Any doc still recommending
  38 steps / CFG 7.0 / CLIP_SKIP 2 as a smoke test is stale — those numbers
  predate the current checkpoint and have been corrected in `README.md` and
  `AGENTS.md`.)
- **Genre nouns in `prompt_2` hijack the subject.** A run carrying `fantasy,
  science fiction, reflective metal, dark theme, volumetric lighting` on the
  second channel turned `1girl, solo, portrait, holding helmet` into a mecha,
  in all three prompts. SDXL's second text-encoder channel conditions subject
  semantics, not just style. Keep `prompt_2` to rendering / material /
  composition vocabulary — which the notebook's current `PROMPT_2_TAGS` already
  does. That current bundle is still unvalidated on this checkpoint, so when
  you next enable `USE_PROMPT_2`, run a `False` control at the same step count
  alongside it.

## Where to push next

Prompt/step tuning has now produced coherent-but-generic output more than once,
so more prompt engineering is the low-value move (this is the notebook's own
escalation rule). The higher-value levers are the pipeline-level ones already
scaffolded and switched off — `USE_REFINER`, `USE_FINAL_UPSCALER` — or
accepting that the base checkpoint won't carry the style pre-LoRA and building
the golden dataset through the img2img route instead
(`img2img-workflow.md`).

Scale is the other gap: the target is 80-120 candidates → 24-30 selected, and
the pool phase hasn't really begun.

**Keep this file short.** Add a run only when it teaches something that changes
future settings, and delete entries once they stop being actionable. Contact
sheets and metadata live only on the author's machine; this file is the part
that survives a clone.
