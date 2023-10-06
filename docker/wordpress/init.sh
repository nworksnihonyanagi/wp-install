#!/bin/bash

# 初期インストール
wp core install \
  --url="http://localhost" \
  --title="Untitled" \
  --admin_user="$WORDPRESS_ADMIN_USER" \
  --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
  --admin_email="$WORDPRESS_ADMIN_EMAIL" \
  --allow-root

# 日本語化
wp language core install "$WORDPRESS_LANGUAGE" --activate --allow-root

# 一般設定
wp option update blogdescription "" --allow-root
wp option update siteurl "http://localhost/wp" --allow-root
wp option update timezone_string "$WORDPRESS_TIMEZONE" --allow-root
wp option update date_format "Y-m-d" --allow-root
wp option update time_format "H:i" --allow-root
wp option update start_of_week "0" --allow-root

# ディスカッション設定
wp option update default_pingback_flag "0" --allow-root
wp option update default_ping_status "closed" --allow-root
wp option update default_comment_status "closed" --allow-root

# パーマリンク設定
wp option update permalink_structure "/%post_id%/" --allow-root
wp rewrite flush --allow-root

# 不要なテーマを削除
wp theme delete twentytwentyone --allow-root
wp theme delete twentytwentytwo --allow-root

# 不要なプラグインを削除
wp plugin delete akismet --allow-root
wp plugin delete hello.php --allow-root

# 不要な投稿・固定ページを削除
wp post delete 1 2 3 --force

# テーマの翻訳をアップデート
wp language theme update --all --allow-root
