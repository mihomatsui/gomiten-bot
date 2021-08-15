require 'active_record'
require 'dotenv/load'

# 環境変数を使って接続する
ActiveRecord::Base.establish_connection(
  adapter: ENV['myadapter'],
  host:    "",
  username: ENV['myusername'],
  password: ENV['mypassword'],
  database: ENV['mydatabase']
)

#クラスを作成 クラス名はDBの一文字目を大文字にする
class Weather < ActiveRecord::Base
end

#1行目のレコードを呼び出す
first_weathers = Weather.first
#全てのレコードを呼び出す
all_weathers = Weather.all

puts "レコードの書式を表示"
p first_weathers

puts "レコードの内容をカラム別に呼び出す"
all_weathers.each do |allweather|
  puts "#{allweather['id']} #{allweather['pref']} #{allweather['area']} #{allweather['latitude']} #{allweather['longitude']} #{allweather['url']} #{allweather['xpath']}"
end