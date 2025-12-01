
# WebS\_original

## 概要

Rubyのマイクロフレームワークである **Sinatra** を使用して構築されたWebアプリケーションです。
フロントエンドのスタイリングには **Tailwind CSS** を採用しており、モダンでレスポンシブなデザインに対応しています。データベース操作には **ActiveRecord** を使用し、**Docker** および **Fly.io** へのデプロイ構成も含まれています。

## 使用技術

本プロジェクトで使用されている主な技術スタックは以下の通りです。

  * **言語:** Ruby, JavaScript, HTML, CSS
  * **フレームワーク:** Sinatra (Ruby)
  * **データベース:** ActiveRecord (ORM), SQLite3 (開発環境), PostgreSQL (本番環境/Fly.io想定)
  * **スタイリング:** Tailwind CSS
  * **パッケージ管理:** Bundler (Ruby), npm (Node.js)
  * **インフラ/デプロイ:** Docker, Fly.io

## 必要条件

このアプリケーションをローカル環境で実行するには、以下のソフトウェアが必要です。

  * **Ruby** (推奨: 3.x系)
  * **Node.js** & **npm** (Tailwind CSSのビルドに必要)
  * **Bundler** (`gem install bundler`)
  * **Git**

## 環境構築

リポジトリをクローンし、必要な依存関係をインストールしてデータベースをセットアップします。

1.  **リポジトリのクローン**

    ```bash
    git clone https://github.com/A3426L/WebS_original.git
    cd WebS_original
    ```

2.  **Ruby依存関係のインストール**

    ```bash
    bundle install
    ```

3.  **Node.js依存関係のインストール**

    ```bash
    npm install
    ```

4.  **データベースのセットアップ**
    マイグレーションを実行してデータベースを作成・更新します。

    ```bash
    bundle exec rake db:migrate
    ```

    *(必要に応じて `bundle exec rake db:seed` 等を実行)*

## 使用方法

アプリケーションとCSSのビルドプロセスを実行します。

### 1\. Tailwind CSS のビルド

Tailwind CSS をビルド（またはウォッチ）します。

```bash
# ビルドのみ
npm run build

# または変更を監視して自動ビルド（package.jsonのscriptsに依存します）
npm run watch
```

*(※ `package.json` の設定によりコマンドが異なる場合があります。例: `npx tailwindcss -i ./public/css/input.css -o ./public/css/output.css --watch` など)*

### 2\. アプリケーションの起動

サーバーを立ち上げます。

```bash
ruby app.rb
# または
bundle exec rackup
```

### 3\. ブラウザでアクセス

ブラウザを開き、以下のURLにアクセスしてください（デフォルトポートの場合）。
`http://localhost:4567` (または `http://localhost:9292`)

-----

### Dockerでの実行（オプション）

Docker環境が整っている場合、以下のコマンドでビルドと起動が可能です。

```bash
docker build -t webs_original .
docker run -p 4567:4567 webs_original
```
