# Azure SRE Agent × GitHub Copilot デモシナリオ

このドキュメントでは、Azure SRE Agent と GitHub Copilot の機能を実際に体験するためのデモシナリオを説明します。

## 前提条件

- Terraform による環境デプロイが完了していること
- Azure Portal へのアクセス権限があること
- GitHub リポジトリへのアクセス権限があること

---

## 1. デプロイした環境の確認

### 1.1 App Service と GitHub の連携確認

1. **Azure Portal** にアクセス
2. リソースグループ `rg-sre-agent-demo` を開く
3. **App Service** を選択
4. 左メニューから **デプロイセンター** を選択
5. 以下を確認：
   - ソース: **GitHub**
   - リポジトリ: 設定した GitHub リポジトリ名
   - ブランチ: **main**
   - ビルドプロバイダー: **GitHub Actions**

6. **GitHub リポジトリ** で `.github/workflows` フォルダを確認
   - Azure が自動生成したワークフローファイルが存在すること

### 1.2 サンプルアプリへのアクセス確認

1. App Service の **概要** ページを開く
2. **既定のドメイン** の URL をクリック（例: `https://app-sreagent-dev-xxxxxx.azurewebsites.net`）
3. サンプルアプリが表示されることを確認する


---

## 2. SRE Agent の設定

### 2.1 SRE Agent へのアクセス

1. **Azure Portal** にアクセス
2. リソースグループ `rg-sre-agent` を開く
3. **SRE Agent** リソースを選択（または検索バーで "SRE Agent" を検索）

### 2.2 アプリリソースに GitHub リポジトリを連携

1. SRE Agent の Monitor -> リソースマッピング を開く
2. 監視対象の App Service が表示されていることを確認
3. App Service を選択し、**リポジトリ連携** をクリック
4. GitHub リポジトリの URL を入力し、承認を行う

### 2.3 インシデント対応計画の編集

1. SRE Agent の Builder -> インシデント対応計画 を開く

2. 既存の計画「quickstart_handler」を選択する

3. Set up incident filters のページで、**I want a custom response plan** 欄にチェックを入れる

3. Define agent learning のページで **指示の追加** 欄に以下の文章を入力する

  ```
  アラート対象リソースがApplication InsightsやLog Analyticsワークスペースであった場合、アラートを上げる要因となったリソースは別に存在するため、ログから特定すること。
  アラート対象リソースにGitHubがリンクされている場合はソースコードも確認すること。
  思考や応答、GitHubへのIssue起票などはすべて日本語で行うこと。
  GitHubにIssueを起票したらGitHub Copilotにアサインすること。
  ```

4. Review custom plan のページで生成された内容を確認する
  - 以下のツールが含まれていることを確認する
    - **CreateGithubIssue**
  - 含まれていない場合は ツールの管理 から追加する

5. Save response plan のページで **詳細な調査を自律的に実行する** にチェックを入れ、保存 をクリック

---

## 3. 疑似インシデント発生

### 3.1 Web アプリで Exception を発生させる

1. サンプルアプリにアクセス
2. **Click me** ボタンをクリックし続ける
3. カウントが 9 より増えないことを確認する（サーバー側では例外が発生している）

### 3.2 Alert の発火確認

1. Azure Portal で Application Insights を開く
2. アラート セクションを確認する
3. **Exception Alert** アラートが発火していることを確認する

### 3.3 SRE Agent のインシデント対応起動

1. SRE Agent の **アクティビティ -> インシデント** セクションを開く
2. 新しいインシデントが検出されていることを確認し、インシデントをクリックして詳細を表示する
3. SRE Agent が対応している状況を眺め、GitHub へ Issue 起票を行ったことを確認する

### 3.4 GitHub リポジトリへの Issue 起票確認

1. GitHub リポジトリ を開く
2. Issues タブを確認し、SRE Agent が自動作成した Issue を確認する
3. Issue に Copilot がアサインされていることを確認する

4. Copilot の対応状況を眺め、Pull Request(PR) が作成されるのを待つ

### 3.6 PR のレビュー・マージ

1. PR の変更内容をレビューし、問題がなければ承認・マージする
2. マージ後、GitHub Actions が自動的にデプロイを開始
3. デプロイ完了後、App Service で修正が反映されていることを確認

## 参考リンク

- [Azure SRE Agent ドキュメント](https://learn.microsoft.com/azure/sre-agent)
- [ソース管理を接続](https://learn.microsoft.com/ja-jp/azure/sre-agent/code-repository-connect?pivots=github)
- [インシデント対応計画の作成](https://learn.microsoft.com/ja-jp/azure/sre-agent/incident-response-plan)