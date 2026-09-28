# heretic-runpod-image

RunPod 用の [Heretic](https://github.com/p-e-w/heretic) イメージ（`--auto-select` 付き）。

- ベース: `runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04`
- 同梱: [quanticsoul4772/heretic](https://github.com/quanticsoul4772/heretic) フォーク（コミット固定）
- `transformers==4.57.6` に固定（Qwen3 対応）

## イメージのビルド

GitHub Actions が Docker Hub へ push する。リポジトリの Secrets に次を登録する。

| Secret | 内容 |
|---|---|
| `DOCKERHUB_USERNAME` | Docker Hub のユーザー名 |
| `DOCKERHUB_TOKEN` | Read/Write 権限のアクセストークン |

登録後、Actions タブから `Build and push Heretic image` を手動実行する。

## RunPod での使い方

Pod の Docker Image に `docker.io/<DOCKERHUB_USERNAME>/heretic:latest` を指定し、
起動コマンド（Container Start Command）に次を入れる。

```sh
bash -lc "heretic prism-ml/Bonsai-8B-unpacked --auto-select --auto-select-path /workspace/bonsai8b-heretic"
```

`--hf-upload <user>/<repo>` を付けると Hugging Face へ直接アップロードできる。

## 注意

このフォークは Heretic 1.0.1 ベースで、公式版が持つ
`chain_of_thought_skips` / `quantization` を持たない。
reasoning モデルでは思考ブロックを拒否と誤検知しうる点、BF16 で載るため
VRAM が 24GB 以上必要（48GB 推奨）な点に注意。
