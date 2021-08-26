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
    result = con.execute("select * from weathers order by abs(latitude - #{latitude}) + abs(longitude - #{longitude}) asc;").first
    puts "#{result['id']},#{result['pref']},#{result['area']},#{result['latitude']},#{result["longitude"]}"
    return result['pref'], result['area']
  end
end