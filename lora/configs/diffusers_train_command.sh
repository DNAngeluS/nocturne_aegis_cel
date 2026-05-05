#!/usr/bin/env bash
set -euo pipefail

# Diffusers SDXL LoRA starter command for nacel_v1.
# Requires a dataset folder or HF dataset with image/caption fields.
# Update MODEL_NAME, DATASET_DIR, and OUTPUT_DIR before running.

MODEL_NAME="OnomaAIResearch/Illustrious-xl-early-release-v0"
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
