require 'dotenv'
require 'pg'
Dotenv.load

class WeatherDbConnector
  # 名古屋市西部
  DEFAULT_AREA_ID = 73

  def initialize
    @conn = PG::connect(
      host: ENV["DB_HOST"],
      dbname: ENV["DB_NAME"],
      user: ENV["DB_USER"],
      port: ENV["DB_PORT"],
      password: ENV["DB_PASSWORD"]
    )
    init
  end
  
  def init
    create_table
    insert_info
  end
 
  def create_table
    #create_weathers_table
    File.open("sql/create_weathers.sql", "r:utf-8") do |f|
      weathersql = f.read
      @conn.exec(weathersql)
    end

    #create_notifications_table
    File.open("sql/notifications.sql", "r:utf-8") do |f|
      notificationsql = f.read
      @conn.exec(notificationsql)
    end
  end

  def insert_info
    #insert_weathers
    File.open("sql/insert_weathers.sql", "r:utf-8") do |f|
      f.each_line do |weathersql|
        @conn.exec(weathersql)
      end
    end
  end

  def set_weather_location(user_id, latitude, longitude)
    result = @conn.exec(%{select * from weathers order by abs(latitude - #{latitude}) + abs(longitude - #{longitude}) asc;}).first
    puts %{#{result["id"]},#{result["pref"]},#{result["area"]},#{result["latitude"]},#{result["longitude"]}}
    @conn.exec(%{insert into notifications (user_id, area_id) values ('#{user_id}', '#{result["id"]}') on conflict on constraint notifications_pkey do update set user_id = excluded.user_id, area_id = excluded.area_id;})
    return result["pref"], result["area"]
  end

  def get_all_notifications
   results = @conn.exec(%{select * from notifications inner join weathers on notifications.area_id = weathers.id;})
   results.each do |row|
    puts "----------------------------"
    p row
   end
   return results
  end

  def get_notifications(user_id)
    results = @conn.exec(%{select * from notifications inner join weathers on notifications.area_id = weathers.id where notifications.user_id = '#{user_id}';})
    results.each do |row|
      puts "----------------------------"
      p row
    end
    return results.first
  end
end
