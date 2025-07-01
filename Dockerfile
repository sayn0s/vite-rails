FROM ruby:3.1.6

# Node.js 18.x, Yarn, 必要パッケージのインストール
RUN apt-get update -qq && \
    apt-get install -y curl build-essential libpq-dev && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

WORKDIR /app

# Gemfileのみをコピー（Gemfile.lockは削除済みなので除外）
COPY Gemfile ./

# bundlerを更新
RUN gem update bundler
RUN bundle config set --local path vendor/bundle

# package.jsonをコピー（存在する場合）
COPY package.json yarn.lock* ./

# アプリケーションコードをコピー
COPY . .

# bundle install（これでGemfile.lockが新しく生成される）
RUN bundle install --retry 3

# Node.jsの依存関係をインストール
RUN yarn install

# ポート開放
EXPOSE 3001 5173

# デフォルトコマンド
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3001"]