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
    # 絶対値を取得し一番小さい値の地域を設定する
    calculate_point = %{(latitude - #{latitude}) + (longitude - #{longitude})}
    result = Weather.select("weathers, ABS(point) AS calculate_point").order(:calculate_point :asc).first
    puts %{#{result['id']},#{result['pref']},#{result['area']},#{result['latitude']}, #{result['longitude']}}
  end
end