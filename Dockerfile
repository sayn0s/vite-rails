FROM ruby:3.1.6

# Node.js 18.x, Yarn, 必要パッケージのインストール
RUN apt-get update -qq && \
    apt-get install -y curl build-essential libpq-dev && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

WORKDIR /app

# すべてをコピーしてからbundle install
COPY . .

# Gemfile.lockを削除（もしあれば）
RUN rm -f Gemfile.lock

# bundle設定とインストール
RUN gem update bundler
RUN bundle config set --local path vendor/bundle
RUN bundle install --retry 3

# frontendビルド
RUN yarn --cwd frontend install && yarn --cwd frontend build
RUN mkdir -p public && cp -r frontend/dist/* public/

# ポート開放
EXPOSE 3001

# サーバー起動
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3001"]