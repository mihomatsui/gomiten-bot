require 'dotenv'
require 'pg'
Dotenv.load

class WeatherDbConnector
  DEFAULT_WEATHER_HOUR = 7
  DEFAULT_WEATHER_MINUTE = 0
  DEFAULT_AREA_ID = 1

  # 環境変数を使って接続する
  def connect
    connection = PG::connect(
      :host => "localhost",
      :user => ENV["DB_USER"],
      :password => ENV["DB_PASSWORD"],
      :dbname => ENV["DB_NAME"]
    )

    begin
      initialize
      notification_enable_user(user_id)
      notification_disnable_user(user_id)
      set_time(user_id, hour, minute)
      set_location(user_id, latitude, longitude)
      get_all_notifications
      get_notifications(user_id)
      fix_notifications
    ensure
      connection.finish
    end
  end
  
  def initialize
    # 毎回リセットする
    drop_weathers
    create_weathers
    insert_weathers
  end

  def create_weathers
    p 'create_weathers_table'
    File.open('create_weathers.sql', 'r:utf-8') do |f|
      createsql = f.read
      connection.exec(createsql)
    end

    p 'create_notifications_table'
    File.open('notification.sql', 'r:utf-8') do |f|
      notificationsql = f.read
      connection.exec(notificationsql)
    end
  end

  def insert_weathers
    p 'insert_weathers_table'
    File.open('insert_weathers.sql', 'r:utf-8') do |f|
      f.each_line do |createsql|
        connection.exec(createsql)
      end
    end
  end

  def drop_weathers
    p 'drop_weathers_table'
    connection.exec("drop table if exists weathers")
    connection.exec("drop table if exists notifications")
  end

  def notification_enable_user(user_id)
    p 'enable_user'
    connection.exec("insert into notifications (user_id, hour, minute, area_id, notificationDisabled) values ('#{user_id}', #{DEFAULT_WEATHER_HOUR},#{DEFAULT_WEATHER_MINUTE}, #{DEFAULT_AREA_ID}, false) on conflict on constraint notifications_pkey do update set user_id = excluded.user_id, notificationDisabled = excluded.notificationDisabled;")
  end

  def notification_disnable_user(user_id)
    p 'disnable_user'
    connection.exec("insert into notifications (user_id, hour,minute, area_id, notificationDisabled) values ('#{user_id}', #{DEFAULT_WEATHER_HOUR},#{DEFAULT_WEATHER_MINUTE}, #{DEFAULT_AREA_ID}, true) on conflict on constraint notifications_pkey do update set user_id = excluded.user_id, notificationDisabled = excluded.notificationDisabled;")
  end

  def set_time(user_id, hour, minute)
    p 'set_time'
    connection.exec("insert into notifications (user_id, hour,minute, area_id, notificationDisabled) values ('#{user_id}', #{hour},#{minute}, #{DEFAULT_AREA_ID}, true) on conflict on constraint notifications_pkey do update set user_id = excluded.user_id, hour = excluded.hour, minute = excluded.minute;")
  end

  def set_location(user_id, latitude, longitude)
    p 'set_location'
    result = connection.exec("select * from weathers order by abs(latitude - #{latitude}) + abs(longitude - #{longitude}) asc;").first
    puts "#{result["id"]},#{result["pref"]},#{result["area"]},#{result["latitude"]},#{result["longitude"]}"
    connection.exec("insert into notifications (user_id, hour, minute, area_id) values ('#{user_id}', #{DEFAULT_WEATHER_HOUR},#{DEFAULT_WEATHER_MINUTE},'#{result["id"]}') on conflict on constraint notifications_pkey do update set user_id = excluded.user_id, area_id = excluded.area_id;")
    return result["pref"], result["area"]
  end

  def get_all_notifications
   p 'get_all_notifications'
   results = connection.exec('select * from notifications inner join weathers on notifications.area_id = weathers.id;')
   results.each do |row|
    puts "----------------------------"
    p row
   end
   return results
  end

  def get_notifications(user_id)
    p 'get_notifications(user_id)'
    results = connection.exec("select * from notifications inner join weathers on notifications.area_id = weathers.id where notifications.user_id = '#{user_id}';")
    results.each do |row|
      puts "----------------------------"
      p row
    end
    return results.first
  end

  def fix_notifications
    p 'fix_notifications'
    connection.exec("update notifications set hour = 7, minute = 0 where hour is null")
  end
end
