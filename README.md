# Cloud Resume Challenge (AWS)

**最終更新 / Last updated:** 2026-11-10 (JST)

運用保守・障害対応の経験を、AWSの構築・自動化へつなげるための個人プロジェクトです。
生成AIを学習支援として活用し、AWSの設定・実装・デプロイを自分で行っています。

A personal [Cloud Resume Challenge](https://cloudresumechallenge.dev/) project connecting IT operations experience with hands-on AWS configuration, deployment automation, and testing. I used generative AI as a learning aid and performed the configuration, implementation, and deployment myself.

🌐 **Live:** https://d23dnziyuzdous.cloudfront.net

## アーキテクチャ / Architecture

```
ブラウザ ──HTTPS──▶ CloudFront ──OAC──▶ S3（非公開バケット）
   │                                     index.html / en.html / style.css / counter.js
   │
   └─ counter.js ──▶ API Gateway (HTTP API, GET /count)
                         │
                         ▼
                      Lambda (Python) ──▶ DynamoDB（アクセス数）
```

| サービス | 役割 |
|---|---|
| Amazon S3 | 静的ファイル（HTML/CSS/JS）の保存。パブリックアクセスはすべてブロック |
| Amazon CloudFront | HTTPS での配信とキャッシュ。Origin Access Control (OAC) で S3 へのアクセスを CloudFront のみに制限 |
| Amazon API Gateway | HTTP API。CORS でこのサイトのオリジンのみ許可 |
| AWS Lambda | アクセス数を 1 増やして返す（Python） |
| Amazon DynamoDB | API呼び出しに対するカウントを保存。`ADD` による原子的な加算で読み取り後の上書きを回避 |
| AWS IAM | DynamoDB操作の対象を限定するインラインポリシー。現行コードが使う操作は`UpdateItem`。Terraformで管理 |

## 工夫した点 / Design decisions

- **S3 を公開しない**：静的ウェブサイトホスティングではなく、CloudFront + OAC 経由でのみ配信
- **権限の限定**：DynamoDBアクセスを対象テーブルに限定する設計。現行のLambdaコードは`UpdateItem`のみを使用し、ログ出力には別途CloudWatch Logsの権限が必要。ポリシーは `infra/` で管理。ただし実行ロールには `PowerUserAccess` も付いており、最小権限化は未完了（後述）
- **アトミックカウンター**：読み取り→加算→書き込みではなく、DynamoDB の `ADD` 式で競合を防止
- **CORS の限定**：ブラウザ向けに許可オリジンを限定。CORSは認証や外部クライアントからの呼び出し防止の代わりにはならない
- **日英バイリンガル**：ページ右上で日本語 / English を切り替え
- **CI/CD**：`frontend/` を変更して push すると、GitHub Actions が S3 へ同期し CloudFront のキャッシュを無効化
- **テスト → デプロイ**：`backend/` を変更して push すると、pytest + moto（DynamoDB をモック）でユニットテストを実行し、全て成功した場合のみ Lambda のコードを更新
- **IaC（Terraform）**：コンソールで作成済みのバックエンド9リソースを `import` ブロックでコード化し、`terraform plan` で差分ゼロを確認。Lambda のコードは GitHub Actions、設定は Terraform と責務を分離
- **認証に関する制約**：アカウントのSCPによりOIDC Providerの作成が制限されているため、現在のワークフローはGitHub Secretsに設定したアクセスキーを使用。キーの値はリポジトリに含めない

## 本人の担当 / My contribution

- S3・CloudFront・OACを用いた配信設定
- API Gateway・Lambda・DynamoDBによるアクセスカウンターの構築・実装
- 日英文ページとGitHub Actionsのデプロイワークフロー
- pytest・MotoによるLambdaの単体テスト
- Terraformによる既存バックエンドリソースのimport・コード化

小規模な静的サイトとカウンターという要件に合わせ、常駐サーバーの管理を避けられるマネージドサービスを選択しています。バックエンド（API Gateway・Lambda・DynamoDB・IAM）はTerraformで管理しています。S3・CloudFrontのコード化は今後対応します。

## ローカル開発 / Local development

リポジトリルートで実行します。CIのPythonバージョンは3.14です。フロントエンドにビルド処理はありません。

```bash
python3.14 -m venv .venv
.venv/bin/python -m pip install -r backend/requirements-dev.txt
.venv/bin/python -m pytest -v backend/tests
python3 -m http.server 8000 --bind 127.0.0.1 --directory frontend
```

ローカルの `/index.html`・`/en.html`・`/style.css`・`/counter.js` がHTTP 200で取得できることを確認します。LambdaはHTTPサーバーではなく、単体テストから呼び出します。テストはダミーの認証情報とMotoを使い、実AWSへのアクセスを必要としません。既存のプロファイル名を維持したまま、一時的なテスト用設定・空の認証ファイルを使うため、個人のAWS設定に依存しません。

`counter.js` は本番APIを参照します。ローカルオリジンがCORSで許可されていなければ、カウンターは `---` 表示になります。テスト目的で本番CORSを広げず、ブラウザ検証では通信をモック化するなどして切り分けます。

## インフラ（Terraform） / Infrastructure as Code

コンソールで作成済みのリソースを作り直さず、Terraform の `import` ブロックで管理下に取り込みました。

```bash
cd infra
terraform init
terraform plan   # "No changes." = コードと実環境の差分ゼロ
```

| ファイル | 内容 |
|---|---|
| `providers.tf` | AWS プロバイダー（`~> 6.0`）と S3 バックエンド |
| `imports.tf` | 取り込んだ9リソースの `import` ブロック |
| `generated.tf` | `terraform plan -generate-config-out` で生成し、エラー箇所を修正したコード |
| `lambda_override.tf` | Lambda のコードは GitHub Actions がデプロイするため、`filename`・`source_code_hash` の変更を無視 |

- **対象**：DynamoDB テーブル、Lambda 関数（設定のみ）、IAM ロールとインラインポリシー、API Gateway（API・統合・ルート・ステージ）、Lambda の呼び出し許可
- **state**：専用の S3 バケットに保存（バージョニング有効、`use_lockfile` による S3 ネイティブロック）。サイト配信用バケットは `s3 sync --delete` を使うため分離
- **実行環境・権限**：GitHub Codespaces で実行。import と plan は読み取りだけで済むため、`ReadOnlyAccess` と state バケットへの書き込みのみを許可した専用 IAM ユーザーを使用。キーは Codespaces Secrets に保存し、リポジトリには含めない
- **import で分かったこと**：Lambda の実行ロールに AWS 管理ポリシー `PowerUserAccess` が付いており、必要以上に広い権限だった。最小権限の専用ロールへの置き換えを次の課題としている

## 検証範囲 / Validation scope

既存の4テストでは以下を確認します。

1. HTTPステータス・JSON形式・カウント項目
2. 初回の値が1になること
3. 連続呼び出しで1ずつ増えること
4. 更新結果がモックDynamoDBに保存されること

これらはモック上の単体テストです。実AWSのIAM、API GatewayのCORS、CloudFront・S3の設定、同時実行、障害復旧まで検証するものではありません。

アクセスカウンターはユニーク訪問者数ではありません。ページ再読込や自動アクセスでも増加し、GETリクエスト自体が更新処理を伴います。再試行時の重複計上を防ぐ設計も未実装です。

## デプロイと権限 / Deployment and permissions

- フロントエンド：`main`への対象変更でS3同期とCloudFront無効化を実行。
- バックエンド：対象のPRでテストを実行し、`main`への対象変更ではテスト後にLambdaコードを更新。
- 手動実行にも対応しますが、デプロイは`main`のみ。PRではバックエンドのテストだけを実行し、バックエンドワークフロー自体の変更もテスト対象です。
- フロントエンド・Lambdaそれぞれのデプロイを直列化し、実行中の処理はキャンセルしません。GitHubの並行実行制御は全コミットの厳密なFIFO実行を保証するものではありません。
- ワークフローのGitHubトークン権限は`contents: read`。各ActionはNode.js 24対応版を使用します。
- フロントエンドの配信先バケット・ディストリビューションへの権限に加え、バックエンドの更新には対象Lambdaへの`lambda:UpdateFunctionCode`が必要です。実際のポリシーはAWS側で確認します。
- GitHub Secretsの名前は`AWS_ACCESS_KEY_ID`と`AWS_SECRET_ACCESS_KEY`。単体テストや静的ページ配信のローカル起動には不要です。

バックエンドのIAM・CORS設定は `infra/` で管理しています。S3・CloudFront・OACの設定はまだリポジトリ外です。READMEは設計の説明であり、稼働中設定の監査証跡ではありません。公開サイトとコードはポートフォリオ用で、住所・電話番号・年収・在留情報を含む応募書類は置きません。

## 応募書類 / Public resumes

- [履歴書（公開版PDF）](docs/resume/resume.pdf) / [編集用Markdown](docs/resume/resume.md)
- [職務経歴書（公開版PDF）](docs/resume/work-history.pdf) / [編集用Markdown](docs/resume/work-history.md)

公開版には業務経験・資格・個人開発を掲載しています。住所、電話番号、年収、在留期限などを含む選考提出用の完全版とは分けて管理します。公開範囲と更新方法は[応募書類の説明](docs/resume/README.md)を参照してください。

## ディレクトリ構成 / Structure

```
frontend/              サイトのファイル（S3 にアップロード）
backend/               Lambda 関数のコード
backend/tests/         ユニットテスト（pytest + moto）
infra/                 Terraform（既存のバックエンドリソースを import）
.github/workflows/     GitHub Actions（自動デプロイ）
docs/resume/          公開用の履歴書・職務経歴書（PDF・Markdown）
```

## 今後の予定 / Roadmap

- [x] S3 + CloudFront で静的サイトを公開
- [x] API Gateway + Lambda + DynamoDB でアクセスカウンター
- [x] Terraform でバックエンドをコード化（既存リソースを import、plan 差分ゼロ）
- [ ] Lambda の実行ロールを最小権限の専用ロールに置き換え
- [ ] S3・CloudFront の Terraform 化
- [ ] ログ・メトリクスに基づく監視と、調査・復旧手順の整備
- [x] デプロイを`main`に限定し、並行実行を制御
- [ ] ロールバック手順、認証方式の見直し
- [x] Lambda のユニットテスト（pytest + moto）と自動デプロイ
- [ ] 独自ドメイン
- [ ] Qiita に構築記録を投稿
