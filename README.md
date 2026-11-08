# Cloud Resume Challenge (AWS)

AWS 上にサーバーレス構成で構築した職務経歴サイトです。
A serverless resume website built on AWS as part of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/).

🌐 **Live:** https://d23dnziyuzdous.cloudfront.net

## アーキテクチャ / Architecture

```
ブラウザ ──HTTPS──▶ CloudFront ──OAC──▶ S3（非公開バケット）
   │                                     index.html / en.html / style.css / counter.js
   │
   └─ counter.js ──▶ API Gateway (HTTP API, GET /count)
                         │
                         ▼
                      Lambda (Python) ──▶ DynamoDB（訪問者数）
```

| サービス | 役割 |
|---|---|
| Amazon S3 | 静的ファイル（HTML/CSS/JS）の保存。パブリックアクセスはすべてブロック |
| Amazon CloudFront | HTTPS での配信とキャッシュ。Origin Access Control (OAC) で S3 へのアクセスを CloudFront のみに制限 |
| Amazon API Gateway | HTTP API。CORS でこのサイトのオリジンのみ許可 |
| AWS Lambda | 訪問者数を 1 増やして返す（Python） |
| Amazon DynamoDB | 訪問者数を保存。`ADD` によるアトミック更新で同時アクセスでも正確にカウント |
| AWS IAM | Lambda の実行ロールに対象テーブルの `UpdateItem` / `GetItem` のみ許可（最小権限） |

## 工夫した点 / Design decisions

- **S3 を公開しない**：静的ウェブサイトホスティングではなく、CloudFront + OAC 経由でのみ配信
- **最小権限**：Lambda には 1 テーブル・2 操作のみを許可するインラインポリシーを付与
- **アトミックカウンター**：読み取り→加算→書き込みではなく、DynamoDB の `ADD` 式で競合を防止
- **CORS の限定**：API はこのサイトのオリジンからの `GET` のみ許可
- **日英バイリンガル**：ページ右上で日本語 / English を切り替え
- **CI/CD**：`frontend/` を変更して push すると、GitHub Actions が S3 へ同期し CloudFront のキャッシュを無効化
- **テスト → デプロイ**：`backend/` を変更して push すると、pytest + moto（DynamoDB をモック）でユニットテストを実行し、全て成功した場合のみ Lambda のコードを更新
- **デプロイ用 IAM ユーザーも最小権限**：本来は OIDC を使いたかったが、アカウントの SCP で ID プロバイダーの作成が禁止されているため、対象バケットへの書き込みと対象ディストリビューションの無効化のみを許可したアクセスキーを GitHub Secrets に保存

## ディレクトリ構成 / Structure

```
frontend/              サイトのファイル（S3 にアップロード）
backend/               Lambda 関数のコード
backend/tests/         ユニットテスト（pytest + moto）
.github/workflows/     GitHub Actions（自動デプロイ）
```

## 今後の予定 / Roadmap

- [x] S3 + CloudFront で静的サイトを公開
- [x] API Gateway + Lambda + DynamoDB で訪問者カウンター
- [x] GitHub Actions による自動デプロイ（CI/CD）
- [ ] Terraform によるインフラのコード化（IaC）
- [x] Lambda のユニットテスト（pytest + moto）と自動デプロイ
- [ ] 独自ドメイン
- [ ] Qiita に構築記録を投稿
