# frozen_string_literal: true

source "https://rubygems.org"
source "https://rails-assets.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# gem "rails"

gem "sinatra"
gem "dotenv"
gem "line-bot-api"
gem "pg"
gem "clockwork"
# Bundlerで自動requireできるように
gem "sinatra-asset-pipeline", require: "sinatra/asset_pipeline"
# JavaScriptの圧縮に必要
gem "uglifier"

#gem "compass"

gem "rake"
# Rails Assetsの中にRails以外でも使いやすくする変更があるので導入
gem "rails-assets-normalize.css"

# 開発環境だけ
group :development do
  gem "sinatra-contrib"
  gem "pry"
end