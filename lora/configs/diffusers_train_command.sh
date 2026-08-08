#!/usr/bin/env bash
set -euo pipefail

# Diffusers SDXL LoRA starter command for nacel_v1.
# Requires a dataset folder or HF dataset with image/caption fields.
# Update MODEL_NAME, DATASET_DIR, and OUTPUT_DIR before running.
#
# Canonical base model for this project (see lora/README.md and
# .agents/lora-training.md for the decision + alternatives). NOTE:
# OnomaAIResearch/Illustrious-XL-v2.0 ships as a single safetensors file, not
# a Diffusers-format repo. train_text_to_image_lora_sdxl.py loads
# MODEL_NAME via StableDiffusionXLPipeline.from_pretrained(), which expects a
# Diffusers folder layout, so convert once before running this script:
#   python -c "
#   from diffusers import StableDiffusionXLPipeline
#   import torch
#   pipe = StableDiffusionXLPipeline.from_single_file(
#       'Illustrious-XL-v2.0.safetensors', torch_dtype=torch.float16)
#   pipe.save_pretrained('./illustrious_xl_v2_diffusers')
#   "
# then point MODEL_NAME at that local folder. Alternatively, use Kohya's
# sd-scripts (configs/kohya_sdxl_lora_config.toml), which loads the
# single-file checkpoint natively with no conversion step.

MODEL_NAME="OnomaAIResearch/Illustrious-XL-v2.0"
DATASET_DIR="./dataset_final"
OUTPUT_DIR="./nacel_v1_illustriousxl_lora"

accelerate launch train_text_to_image_lora_sdxl.py \
  --pretrained_model_name_or_path="$MODEL_NAME" \
  --train_data_dir="$DATASET_DIR" \
  --caption_column="text" \
  --resolution=1024 \
  --random_flip \
  --train_batch_size=1 \
  --gradient_accumulation_steps=4 \
  --max_train_steps=2000 \
  --checkpointing_steps=250 \
  --learning_rate=1e-4 \
  --lr_scheduler="cosine" \
  --lr_warmup_steps=100 \
  --rank=32 \
  --mixed_precision="bf16" \
  --seed=23111990 \
  --output_dir="$OUTPUT_DIR"
