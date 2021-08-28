require 'active_record'
require 'dotenv/load'

class WeatherDbConnector
  DEFAULT_WEATHER_HOUR = 7
  DEFAULT_WEATHER_MINUTE = 0

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

  def initialize
    @conn = ActiveRecord::Base.connection
    # 毎回リセットする
    drop_weathers
    # テーブルの作成
    create_weathers
    # データを挿入する
    insert_weathers
  end

  def create_weathers
    p 'create_table'
    File.open('create_weathers.sql', 'r:utf-8') do |f|
      createsql = f.read
      @conn.execute(createsql)
    end

    File.open("notification.sql", "r:utf-8") do |f|
      notificationsql = f.read
      @conn.execute(notificationsql)
    end
  end

  def insert_weathers
    p 'insert_weathers_table'
    File.open('insert_weathers.sql', 'r:utf-8') do |f|
      f.each_line do |createsql|
        @conn.execute(createsql)
      end
    end
  end

  def drop_weathers
    p 'drop_weathers_table'
    weathers = Weather.table_name
    @conn.drop_table(weathers)
  end

  def set_location(user_id, latitude, longitude)
    p 'set_location'
    result = @conn.execute("select * from weathers order by abs(latitude - #{latitude}) + abs(longitude - #{longitude}) asc;").first
    puts "#{result['id']},#{result['pref']},#{result['area']},#{result['latitude']},#{result['longitude']}"
    return result['pref'], result['area']
  end

  def notification_enable_user
    p 'enable_user'
    @conn.execute("insert into notifications (user_id, hour,minute, notification_disabled) values ('#{user_id}', #{DEFAULT_WEATHER_HOUR},#{DEFAULT_WEATHER_MINUTE}, false")
  end

  def notification_disnable_user
    p 'disnable_user'
    @conn.execute("insert into notifications (user_id, hour,minute, notification_disabled) values ('#{user_id}', #{DEFAULT_WEATHER_HOUR},#{DEFAULT_WEATHER_MINUTE}, true")
  end
end
