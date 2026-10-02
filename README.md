# Reports.Web engine (Docker image)

`ghcr.io/reportsweb/engine` — **Reports.Web** の帳票エンジン（C++ WebAssembly）です。印刷データ（PREPEJ / JSON）を HTTP で受け取り、PDF を返します。PHP・Java・.NET・Go・Ruby・Rust・Node.js のどの言語からも、同じエンジンで同じ帳票を出力できます。

The Reports.Web report engine (C++ WebAssembly) as a Docker image. POST print data (PREPEJ JSON) and get a PDF back — the same engine and the same output for PHP, Java, .NET, Go, Ruby, Rust and Node.js.

- 製品サイト / Product: https://www.pao.ac/reports.web/
- サンプル / Samples: https://github.com/ReportsWeb

## 起動 / Run

```sh
docker run -d --name reports-web-engine -p 3107:3107 ghcr.io/reportsweb/engine:1.0.1
curl http://127.0.0.1:3107/health        # {"status":"ok","engine":"C++ WebAssembly"}
curl -X POST -H "Content-Type: application/json" --data-binary @print-data.json \
     http://127.0.0.1:3107/render/pdf -o report.pdf
```

## API

| メソッド | パス | 内容 |
|---|---|---|
| `GET` | `/health` | エンジンの状態 / Engine status |
| `POST` | `/render/pdf` | 印刷データ（PREPEJ JSON、最大 32 MiB）を PDF に。応答は `application/pdf`、ヘッダー `X-Reports-Engine: server-wasm` |

- 要求は 1 件ずつ順番に処理します（キューで直列化）。/ Requests are processed one at a time.
- 画像は、印刷データに埋め込んだ PNG・JPEG・GIF だけを受け付けます。エンジンが外部の URL を取りに行くことはありません。/ Images must be embedded (PNG, JPEG, GIF); the engine never fetches URLs.
- `X-Reports-Swap-Pdf-Image: true` を付けると、大きな画像を一時ファイルに逃がしてメモリを節約します。

## ブラウザー用ランタイム / Browser runtime

イメージには、ブラウザで動くデザイナー・プレビュー画面のファイル（`/opt/reports.web`）も入っています。サンプルはこれを Docker ボリュームに取り出して使います。

```sh
docker volume create reports-web-runtime
docker run --rm -u root -v reports-web-runtime:/export ghcr.io/reportsweb/engine:1.0.1 export-runtime
```

## 体験版と製品版 / Trial and product

このイメージは体験版です。出力には赤い「SAMPLE」の印が付きます。ご購入後に納品するライセンスファイルを `/app/reports-web.license` に置く（または `PAO_REPORTS_LICENSE_FILE` で場所を指定する）と、印が消えます。

This image is a trial build: output carries a red "SAMPLE" mark. Mount the license file delivered on purchase:

```sh
docker run -d -p 3107:3107 -v /path/to/reports-web.license:/app/reports-web.license:ro ghcr.io/reportsweb/engine:1.0.1
```

開発用パソコン 1 台につき 1 ライセンス、運用環境はランタイムライセンスフリーです。
- ご購入・お見積もり：https://www.pao.ac/reports.web/buy.html
- 使用許諾：https://www.pao.ac/reports.web/manual/index.html#16

## このリポジトリ / This repository

イメージを作るための `Dockerfile` と説明だけを置いています。エンジン本体のソースは公開していません。
Only the `Dockerfile` and documentation are here; the engine itself is distributed as the prebuilt image.

---
Pao@Office — https://www.pao.ac/ — info@pao.ac

## 版 / Versions

- `1.0.1`（`latest`、2026-10-03）：帳票の中のバーコードは、Barcode.wasm と同じ体験版のビルドを使います。帳票の出力は 1.0.0 と同じです。 / The embedded barcode module is the same trial build as Barcode.wasm; report output is identical to 1.0.0.
- `1.0.0`：既に使っている環境のために残しています。新しく使う場合は 1.0.1 を指定してください。 / Kept for existing users; use 1.0.1 for new setups.
