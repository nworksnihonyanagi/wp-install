# プロジェクト名
プロジェクトに合わせて適宜内容を変更してください。

<!------------------------------------->

## 開発環境

### 必須

- [Docker](https://www.docker.com/products/docker-desktop)
- [Node.js](https://nodejs.org/ja/)

### 推奨（VS Codeの拡張機能）

- [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=editorconfig.editorconfig)
- [Prettier - Code formatter](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [Stylelint](https://marketplace.visualstudio.com/items?itemName=stylelint.vscode-stylelint)

<!------------------------------------->

## ディレクトリ・ファイル構成

### リポジトリ内の配置

```
├── docker (1)
│   ├── mysql
│   │   └── init.sql.gz
│   └── wordpress
│       └── init.sh
├── public (2)
│   ├── wp
│   ├── .htaccess
│   └── index.php
├── vendor (3)
├── .env (4)
├── composer.json (5)
└── composer.lock (6)
```

### Dockerコンテナ内の配置

```
├── docker (1)
│   ├── mysql
│   │   └── init.sql.gz
│   └── wordpress
│       └── init.sh
└── var
    └── www
         ├── html (2)
         │   ├── wp
         │   ├── .htaccess
         │   └── index.php
         ├── vendor (3)
         ├── .env (4)
         ├── composer.json (5)
         └── composer.lock (6)
```

### 主なファイル・ディレクトリ

| パス | 説明 |
| - | - |
| `docker/mysql/init.sql.gz` | Dockerコンテナの起動時に実行されるSQLファイル |
| `docker/wordpress/init.sh` | WordPressのインストール用のスクリプト |
| `public` | ウェブサーバのドキュメントルート |
| `public/wp` | WordPressのインストール場所 |
| `vendor` | Composerパッケージのインストール場所 |
| `.env` | 環境変数の設定 |
| `composer.json` | Composerパッケージの設定 |

<!------------------------------------->

## セットアップ（初回のみ）

### 環境変数

`.env` が無い場合は `.env.sample` をコピーして作成します。

| 環境変数 | 値 | 説明 |
| - | - | - |
| WORDPRESS_DEBUG | デバッグの有効化 | `0`: 無効、`1`: 有効 |
| WORDPRESS_LANGUAGE | [サイトの言語](https://make.wordpress.org/polyglots/teams/) | 初期化時に使用 |
| WORDPRESS_TIMEZONE | [サイトのタイムゾーン](https://www.php.net/manual/en/timezones.php) | 初期化時に使用 |
| WORDPRESS_ADMIN_USER | 管理者のユーザー名 | 初期化時に使用 |
| WORDPRESS_ADMIN_PASSWORD | 管理者のパスワード | 初期化時に使用 |
| WORDPRESS_ADMIN_EMAIL | 管理者のメールアドレス | 初期化時に使用 |

### npmパッケージをインストール

```sh
npm install
```

<!------------------------------------->

## WordPressの初期化

### WordPressのコアファイルを生成

Dockerコンテナの初回起動時に `public/wp` の配下にWordPressに必要なファイルが自動生成されます。

```sh
docker-compose up -d
```

### WordPressをインストール

`public/wp/wp-config.php` が生成された事を確認した後に、
インストール用のスクリプトを実行します。

```sh
docker-compose exec -u www-data wordpress bash /docker/wordpress/init.sh
```

不要な初期テーマとプラグインは削除、いくつかの設定項目の初期値が変更されます。

| 設定項目 | 設定値 | 初期値 |
| - | - | - |
| 一般 &raquo; 日付形式 | `Y-m-d` | カスタム `F j, Y` |
| 一般 &raquo; 時刻形式 | `H:i` | カスタム `g:i a` |
| 一般 &raquo; 週の始まり | 日曜日 | 月曜日 |
| ディスカッション &raquo; デフォルトの投稿設定 | すべてOFF | すべてON |
| メディア &raquo; サムネイルのサイズ &raquo; 幅 | `0` | `150` |
| メディア &raquo; サムネイルのサイズ &raquo; 高さ | `0` | `150` |
| パーマリンク設定 &raquo; 共通設定 | カスタム構造 `/%post_id%/` | 日付と投稿名 |

<!------------------------------------->

## 使い方

### Dockerコンテナを起動

```sh
docker-compose up -d
```

| URL | 説明 |
| - | - |
| http://localhost/ | WordPress |
| http://localhost/wp/wp-admin/ | WordPressの管理画面 |
| http://localhost:8080 | phpMyAdmin |
| http://localhost:8025 | MailHog |

### Dockerコンテナに入る

```sh
docker-compose exec -u www-data wordpress bash
```

例）データベース内の文字列を検索して置換

```sh
wp search-replace https://example.com http://localhost
```

例）データベースをSQLファイルとしてエクスポート

```sh
wp db export /docker/mysql/example.sql
```

Dockerコンテナから出る

```sh
exit
```

### Dockerコンテナのデータベースを保存

```sh
docker-compose exec -u www-data wordpress bash -c "wp db export - | gzip -c > /docker/mysql/init.sql.gz"
```

### Dockerコンテナを終了

```sh
docker-compose down -v
```

<!------------------------------------->

## Composer

WordPressの他にPHPライブラリが必要な場合に使用できます。

### パッケージのインストール

```sh
docker-compose exec -u www-data -w /var/www wordpress composer install
```

### Dockerコンテナに入る

```sh
docker-compose exec -u www-data -w /var/www wordpress bash
```

例）phpdotenvを追加

```sh
composer require vlucas/phpdotenv
```

Dockerコンテナから出る

```sh
exit
```

### WordPressでの利用方法

`public/wp/wp-config.php` で `vendor/autoload.php` を読み込みます。

```php
define('COMPOSER_WORKING_DIR', dirname(dirname(__DIR__)));
require COMPOSER_WORKING_DIR . '/vendor/autoload.php';

// 例）phpdotenvを利用
$dotenv = Dotenv\Dotenv::createImmutable(COMPOSER_WORKING_DIR);
$dotenv->load();
```
