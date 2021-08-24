require 'active_record'
require 'dotenv/load'

class WeatherDbConnector
  # 環境変数を使って接続する
  ActiveRecord::Base.establish_connection(
    adapter: ENV['myadapter'],
    host:    "",
    username: ENV['myusername'],
    password: ENV['mypassword'],
    database: ENV['mydatabase']
  )

  # クラスを作成
  class Weather < ActiveRecord::Base
  end

  def set_location(user_id, latitude, longitude)
    p 'set_location'

    # 緯度経度を計算して絶対値を取得する
    @weathers = Weather.all
    abs = 'abs(latitude - #{latitude}) + abs(longitude - #{longitude})'
    @weathers.update(abs: abs)
    result = Weather.order(:abs).first
    return result['pref'], result['area']
  end
end