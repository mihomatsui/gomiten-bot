class HourJob
  # 指定時間に実行
  def call
    require './app'
    weather_info_conn = WeatherInfoConnector.new
    now_time = Time.now
    begin
    $db.get_all_notifications.each do |row|
      if row['notificationDisabled'] == false then
        hour = row['hour'] || 7
        minute = row['minute'] || 0
        next if hour != (now_time.hour + 9) % 24 # GMTからJISに変換 早期リターン
        next if minute != now_time.min
        set_day = hour < 6 ? 1 : 0 # weatherapiは朝6時に更新
        forecast = weather_info_conn.get_weatherinfo(row['pref'], row['area'], row['url'].sub(/http/, 'https'), row['xpath'], set_day)
        puts %{#{hour}:#{minute} - #{forecast}}
        message = { type: 'text', text: forecast }
        p 'push message'
      
        case forecast
        when /.*(雨|雪).*/ 
          message_sticker = {"type": "sticker", "packageId": "446", "stickerId": "1994"}
          messages = [message, message_sticker]
          p client.push_message(row['user_id'], messages)
        else
          p client.push_message(row['user_id'], message)
        end  
      end
    end
    rescue => e
      p e
    end
    "OK"
  end
end
