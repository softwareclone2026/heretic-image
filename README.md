# heretic-image

RunPod 用の [Heretic](https://github.com/p-e-w/heretic) イメージ。Bonsai-8B のような
reasoning モデルでも、Pod の起動コマンドから**完全に非対話**で uncensored 化できる。

## 中身

| 項目 | 内容 |
|---|---|
| ベース | `runpod/pytorch:1.3.3-cu1281-torch2130-ubuntu2404`（torch 2.13 / CUDA 12.8.1 / Ubuntu 24.04） |
| Heretic | 本家 master（`2.0.0.dev0`）をコミット `3521f864` に固定 |
| 依存 | `transformers~=5.6` / `bitsandbytes~=0.49` / `optuna~=4.7` / `lm-eval~=0.4` など |
| 追加 | `hf_transfer`（16GB 級の重みを高速取得） |

PyPI の最新リリースは v1.4.0 だが、v1.4.0 は保存が対話式で Pod の起動コマンドから
扱えない。master は `--model-action save` / `--save-directory` / `--checkpoint-action`
に対応しており、`chain_of_thought_skips` や `--quantization bnb_4bit` も持つ。

## ビルド

GitHub Actions（`.github/workflows/build.yml`）が push する。

- GHCR: `ghcr.io/<owner>/heretic:latest` … Secrets 不要（既定の `GITHUB_TOKEN` を使用）
- Docker Hub: `docker.io/<user>/heretic:latest` … リポジトリの Secrets に
  `DOCKERHUB_USERNAME` と `DOCKERHUB_TOKEN`（Read/Write トークン）を登録した場合のみ

Docker Hub のトークンは https://hub.docker.com/settings/security で発行する。
Secrets が無くても GHCR へのビルドは実行される。

## RunPod での使い方

Pod の Docker Image に次を指定する（GHCR のパッケージを public にしておく）。

```
ghcr.io/<owner>/heretic:latest
```

起動コマンド（Container Start Command）:

```sh
bash -lc "heretic prism-ml/Bonsai-8B-unpacked --model-action save --save-directory /workspace/bonsai8b-heretic --export-strategy merge"
```

主なオプション:

| オプション | 用途 |
|---|---|
| `--quantization bnb_4bit` | 4bit で読み込み、VRAM 使用量を大きく下げる |
| `--n-trials 200` | 最適化の試行回数（既定 200） |
| `--max-response-length 100` | 1 応答あたりの最大トークン数 |
| `--checkpoint-action continue` | `checkpoints/` があれば続きから再開 |
| `--upload-repo-id <user>/<repo>` | 保存と同時に Hugging Face へアップロード |

VRAM の目安は 10 億パラメータあたり約 2.5GB。BF16 の 8B なら 24GB 以上、
48GB あると余裕がある。`bnb_4bit` を使えば 16GB 級でも扱いやすい。
