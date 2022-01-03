require 'dotenv'
require 'pg'
require './garbage_date_check/garbage_search'
Dotenv.load

$search = GarbageSearch.new

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
    result = @conn.exec(%{SELECT schemaname, tablename, tableowner 
    from pg_tables WHERE schemaname NOT LIKE 'pg_%' and schemaname != 'information_schema';})
    init if result.count == 0
  end
  
  def init
    create_table
    insert_info
  end
 
  def create_table
    File.open("sql/create_weathers.sql", "r:utf-8") do |f|
      weathersql = f.read
      @conn.exec(weathersql)
    end

    File.open("sql/notifications.sql", "r:utf-8") do |f|
      notificationsql = f.read
      @conn.exec(notificationsql)
    end

    File.open("sql/create_garbages.sql", "r:utf-8") do |f|
      garbagesql = f.read
      @conn.exec(garbagesql)
    end
  end

  def insert_info
    File.open("sql/insert_weathers.sql", "r:utf-8") do |f|
      weathersql = f.read
      @conn.exec(weathersql)
    end

    File.open("sql/insert_garbages.sql", "r:utf-8") do |f|
      garbagesql = f.read
      @conn.exec(garbagesql)
    end
  end

  def set_weather_location(user_id, latitude, longitude)
    result = @conn.exec(%{SELECT * FROM weathers ORDER BY ABS(latitude - #{latitude}) + ABS(longitude - #{longitude}) ASC;}).first
    puts %{#{result["id"]},#{result["pref"]},#{result["area"]},#{result["latitude"]},#{result["longitude"]}}
    @conn.exec(%{INSERT INTO notifications (user_id, area_id) VALUES ('#{user_id}', '#{result["id"]}') ON CONFLICT ON CONSTRAINT notifications_pkey DO UPDATE SET user_id = excluded.user_id, area_id = excluded.area_id;})
    return result["pref"], result["area"]
  end

  def get_all_notifications
   results = @conn.exec(%{SELECT * FROM notifications INNER JOIN weathers ON notifications.area_id = weathers.id;})
   results.each do |row|
    puts "----------------------------"
    p row
   end
   return results
  end

  def get_notifications(user_id)
    results = @conn.exec(%{SELECT * FROM notifications INNER JOIN weathers ON notifications.area_id = weathers.id WHERE notifications.user_id = '#{user_id}';})
    results.each do |row|
      puts "----------------------------"
      p row
    end
    return results.first
  end

  def get_garbages
    # 週と曜日を取得
    tomorrow = $search.nth_day_of_week(now: Time.current.tomorrow)
    tomorrow_nth = tomorrow[:nth]
    tomorrow_wday = tomorrow[:wday]
    # テキストメッセージから地域を取得
    # 地域、週、曜日で検索してtypeを抜き出す
    result = @conn.exec(%{SELECT * FROM garbages WHERE area = #{garbage_area} AND wday = #{tomorrow_wday} AND (nweek = #{tomorrow_nth} OR nweek = 0;})
    
    # 該当件数あれば明日の〇〇地域は××の日です
    if result.count == 0
     message = ''
     message << %{明日(#{Time.current.tomorrow.strftime("%m月%d日%a")})は、}
     message << %{特に出せるゴミはありません}
    else
     message = ''
     message << %{明日(#{Time.current.tomorrow.strftime("%m月%d日%a")})は、}
     message << %{#{result["type"]}の日です}
    end
    return message
  end
end
