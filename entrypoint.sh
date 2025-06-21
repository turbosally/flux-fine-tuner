#!/usr/bin/env bash
set -e

# Determine mode: "train" or "predict" (from env or first arg)
MODE=${MODE:-$1}
MODE=$(echo "$MODE" | tr '[:upper:]' '[:lower:]')

# Base Cog command
COG_CMD="cog run"

if [ "$MODE" = "train" ]; then
  echo "🚀 Running FLUX LoRA training"
  : "${INPUT_IMAGES:?Error: INPUT_IMAGES must be set (path or URL to .zip)}"
  : "${TRIGGER_WORD:?Error: TRIGGER_WORD must be set}"
  STEPS=${STEPS:-1000}
  AUTOCAPTION=${AUTOCAPTION:-true}

  $COG_CMD train \
    -i input_images="$INPUT_IMAGES" \
    -i trigger_word="$TRIGGER_WORD" \
    -i steps="$STEPS" \
    -i autocaption="$AUTOCAPTION"

elif [ "$MODE" = "predict" ]; then
  echo "🎨 Running FLUX LoRA inference"
  : "${LORA_WEIGHTS:?Error: LORA_WEIGHTS must be set (path or URL to .safetensors)}"
  : "${PROMPT:?Error: PROMPT must be set}"

  # Inference options with sane defaults
  MODEL=${MODEL:-dev}
  GO_FAST=${GO_FAST:-false}
  LORA_SCALE=${LORA_SCALE:-1}
  EXTRA_LORA_SCALE=${EXTRA_LORA_SCALE:-1}
  MEGAPIXELS=${MEGAPIXELS:-1}
  NUM_OUTPUTS=${NUM_OUTPUTS:-1}
  ASPECT_RATIO=${ASPECT_RATIO:-1:1}
  OUTPUT_FORMAT=${OUTPUT_FORMAT:-webp}
  GUIDANCE_SCALE=${GUIDANCE_SCALE:-3}
  OUTPUT_QUALITY=${OUTPUT_QUALITY:-80}
  PROMPT_STRENGTH=${PROMPT_STRENGTH:-0.8}
  NUM_INFERENCE_STEPS=${NUM_INFERENCE_STEPS:-28}

  # Handle an optional negative prompt
  NEG_PROMPT_ARG=()
  if [ -n "$NEGATIVE_PROMPT" ]; then
    NEG_PROMPT_ARG=(-i negative_prompt="$NEGATIVE_PROMPT")
  fi

  $COG_CMD predict \
    -i lora_weights="$LORA_WEIGHTS" \
    -i prompt="$PROMPT" \
    "${NEG_PROMPT_ARG[@]}" \
    -i model="$MODEL" \
    -i go_fast="$GO_FAST" \
    -i lora_scale="$LORA_SCALE" \
    -i extra_lora_scale="$EXTRA_LORA_SCALE" \
    -i megapixels="$MEGAPIXELS" \
    -i num_outputs="$NUM_OUTPUTS" \
    -i aspect_ratio="$ASPECT_RATIO" \
    -i output_format="$OUTPUT_FORMAT" \
    -i guidance_scale="$GUIDANCE_SCALE" \
    -i output_quality="$OUTPUT_QUALITY" \
    -i prompt_strength="$PROMPT_STRENGTH" \
    -i num_inference_steps="$NUM_INFERENCE_STEPS"

else
  echo "❌ Error: invalid or missing MODE. Please set MODE=train or MODE=predict"
  exit 1
fi
