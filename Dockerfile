# Heretic (本家 p-e-w/heretic) を RunPod で即使えるようにしたイメージ。
#
# ベースは RunPod 公式の PyTorch イメージ。RunPod の SSH 鍵注入や Web ターミナルを
# そのまま使えるように、ENTRYPOINT / CMD は変更しない。
#
# Heretic の最新リリース v1.4.0 はモデル保存が対話式 (questionary) のみで、
# Pod の起動コマンドからの自動実行に向かない。master (2.0.0.dev0) では
#   --model-action save --save-directory <dir> --checkpoint-action continue
# による完全非対話実行が可能なので、こちらをコミット固定で導入する。
FROM runpod/pytorch:1.3.3-cu1281-torch2130-ubuntu2404

ARG HERETIC_REPO=https://github.com/p-e-w/heretic.git
ARG HERETIC_REF=3521f8648a0dccf6e12a92666862632235fac7e6

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HF_HOME=/workspace/.cache/huggingface \
    HF_HUB_ENABLE_HF_TRANSFER=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends git git-lfs ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# hf_transfer: 16GB 級のモデル重みを高速に取得するため。
# heretic-llm: transformers 5.6 系 / bitsandbytes / optuna / lm-eval などの依存は
# pyproject.toml の指定どおりに解決させる (ビルド時点の版で固定される)。
RUN pip install --no-cache-dir hf_transfer \
 && pip install --no-cache-dir "heretic-llm @ git+${HERETIC_REPO}@${HERETIC_REF}" \
 && python -c "import importlib.metadata as m; print('heretic-llm', m.version('heretic-llm'))" \
 && heretic --help | head -n 3

WORKDIR /workspace
