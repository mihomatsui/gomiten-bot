require 'bundler/setup'
Bundler.require
# 開発環境のみオートリロードをつける
require 'sinatra/reloader' if development?
require './weather_db_connector'
require './weather_info_connector'
require 'date'

$db = WeatherDbConnector.new

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end
  events = client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      user_id = event['source']['userId']
      reply_text = "使い方:\n\n・位置情報を送信してください。\n(トークルーム下部の「+」をタップして、「位置情報」から送信できます。)\n\n"
      reply_text << "・「1」または「スタート」と入力すると、毎日朝7時に天気、\n"
      reply_text << "  夜の21時に翌日のゴミの収集日をお知らせします。\n\n"
      reply_text << "・「2」または「ストップ」と入力すると、停止します。\n\n"
      reply_text << "・「3」または「天気」と入力すると、現在設定されている地域の天気をお知らせします。\n"
      
      case event.type
      when Line::Bot::Event::MessageType::Text
        # 文字列が入力された場合
        case event.message['text']
        when /.*(1|１|スタート).*/
          $db.notification_enable_user(user_id)
          info = $db.get_notifications(user_id)
          reply_text = %{#{info['pref']} #{info['area']} の天気をお知らせします！}
          reply_text << "\n\nお知らせを停止するときは「2」または「ストップ」と入力してください。\n\n地域を設定するときは 位置情報 を送信してください。"
        when /.*(2|２|ストップ).*/
          $db.notification_disnable_user(user_id)
          reply_text = "お知らせの停止を受け付けました。\n\nお知らせを開始するときは「1」または「スタート」と入力してください。\n\n使い方を見たい場合は何か話しかけてください。"
        end
        when /.*(3|３|天気).*/
          weather_info_conn = WeatherInfoConnector.new
          begin
            # weather = WeatherInfoConnector.new('愛知県', '西部', 'http://www.drk7.jp/weather/xml/23.xml', 'weatherforecast/pref/area[2]', 0)
          rescue => e
            reply_text = weather_info_conn.get_weatherinfo('愛知県', '西部', 'http://www.drk7.jp/weather/xml/23.xml', 'weatherforecast/pref/area[2]', set_day = 1) #名古屋駅
            p e
          end
        end
      when Line::Bot::Event::MessageType::Location
        # 位置情報が入力された場合
        
        # 緯度と経度を取得
        latitude = event.message['latitude']
        longitude = event.message['longitude']
        puts "緯度と経度を取得しました！"
        pref, area = $db.set_location(user_id, latitude, longitude)
        reply_text = %{地域を#{pref} #{area}にセットしました！\n\n「3」または「天気」と入力すると、現在設定されている地域の天気をお知らせします。}
        
      end
    end
    message = {
          type: "text",
          text: reply_text
        }
    client.reply_message(event["replyToken"], message)
  end
  "OK"
end
get '/' do
  "Hello world!"
end