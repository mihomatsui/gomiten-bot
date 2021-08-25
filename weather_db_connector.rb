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
    con = ActiveRecord::Base.connection
    result = con.execute('select * from weathers order by abs(latitude - #{latitude}) + abs(longitude - #{longitude}) asc').first
    puts result
    # 緯度経度を計算して絶対値を取得する
    # @weathers = Weather.all
    # point = '(latitude - #{latitude}) +(longitude - #{longitude})'
    # point_abs = (point.to_i).abs
    # p point_abs
    # Weather.update_all(abs: point_abs)
    # result = Weather.order(:abs).first
    return result['pref'], result['area']
  end
end