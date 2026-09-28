# Heretic (quanticsoul4772 フォーク) を RunPod で即使えるようにしたイメージ。
#
# ベースは RunPod 公式の PyTorch イメージ。RunPod の SSH 鍵注入や
# Web ターミナルがそのまま使えるようにエントリポイントは触らない。
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HF_HOME=/workspace/.cache/huggingface \
    HF_HUB_ENABLE_HF_TRANSFER=1

# transformers は Qwen3 対応版に固定する。ここで固定しないと
# 最新の 5.x が入り、Heretic フォークの想定とずれる可能性がある。
RUN pip install --no-cache-dir "transformers==4.57.6" \
 && pip install --no-cache-dir \
      "heretic-llm @ git+https://github.com/quanticsoul4772/heretic.git@855028a4f9a246d0fddd9a7f1e352afda70dcf91" \
 && pip install --no-cache-dir "hf-transfer"

WORKDIR /workspace
