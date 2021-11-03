require 'bundler/setup'
Bundler.require
require 'sinatra'

# 開発環境のみ使用
if development?
  require 'sinatra/reloader'
  require 'pry'
end
require './weather_db_connector'
require './weather_info_connector'
require './helpers/application_helper'
require './garbage_date_check/sukiya'
require './garbage_date_check/sunahara'
require './garbage_date_check/sengen1'
require './garbage_date_check/sengen2'
require './garbage_message'

helpers ApplicationHelper
get '/' do
  erb :top
end

$db = WeatherDbConnector.new

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials ==[ENV['BASIC_AUTH_USERNAME'], ENV['BASIC_AUTH_PASSWORD']]
  end
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = ENV["LINE_CHANNEL_ID"]
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

get '/send' do
  protected! #basic認証
  weather_info_conn = WeatherInfoConnector.new
  begin
  $db.get_all_notifications.each do |row|
    set_day = 0 # weatherapiは朝6時に更新 今日の天気
    forecast = weather_info_conn.get_weatherinfo(row['pref'], row['area'], row['url'].sub(/http/, 'https'), row['xpath'], set_day)
    puts forecast
    message = { type: 'text', text: forecast }
    notificationDisabled = true
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
  rescue => e
    p e
  end
  puts "done."
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
    when Line::Bot::Event::Postback # ポストバックイベント
      LineBot::PostbackEvent.send(event['postback']['data'])
    when Line::Bot::Event::Message
      user_id = event['source']['userId']
      reply_text = "使い方:\n\n・位置情報を送信してください。\n(トークルーム下部の「+」をタップして、「位置情報」から送信できます。)\n\n"
      reply_text << "・毎日朝7時に天気をお知らせします。\n"
      reply_text << "・通知が多い場合はトーク画面右上から設定を変更してください。\n\n"
      reply_text << "・「天気」と入力すると、現在設定されている地域の天気をお知らせします。\n"
      
      case event.type
      when Line::Bot::Event::MessageType::Text
        # 文字列が入力された場合
        case event.message['text']
        when /.*(天気|てんき).*/
          weather_info_conn = WeatherInfoConnector.new
          begin
            info = $db.get_notifications(user_id)
            reply_text = weather_info_conn.get_weatherinfo(info['pref'], info['area'], info['url'].sub(/http/, 'https'), info['xpath'], set_day = 0)
          rescue => e
            reply_text = weather_info_conn.get_weatherinfo('愛知県', '西部', 'https://www.drk7.jp/weather/xml/23.xml', 'weatherforecast/pref/area[2]', set_day = 0) #名古屋駅
            p e
          end
        when /.*(明日|あした).*/
          weather_info_conn = WeatherInfoConnector.new
          begin
            info = $db.get_notifications(user_id)
            reply_text = weather_info_conn.get_weatherinfo(info['pref'], info['area'], info['url'].sub(/http/, 'https'), info['xpath'], set_day = 1)
          rescue => e
            reply_text = weather_info_conn.get_weatherinfo('愛知県', '西部', 'https://www.drk7.jp/weather/xml/23.xml', 'weatherforecast/pref/area[2]', set_day = 1) 
            p e
          end
        when /.*(明後日|あさって).*/
          weather_info_conn = WeatherInfoConnector.new
          begin
            info = $db.get_notifications(user_id)
            reply_text = weather_info_conn.get_weatherinfo(info['pref'], info['area'], info['url'].sub(/http/, 'https'), info['xpath'], set_day = 2)
          rescue => e
            reply_text = weather_info_conn.get_weatherinfo('愛知県', '西部', 'https://www.drk7.jp/weather/xml/23.xml', 'weatherforecast/pref/area[2]', set_day = 2) 
            p e
          end  
        
        when /.*(ゴミ|ごみ).*/
          reply_text = "使い方:\n\n・明日のゴミの収集日をお知らせします。\n(対応地域は下記です。カッコは不要です。)\n\n"
          reply_text << "・名古屋市西区数奇屋\n「数奇屋」または「すきや」\n\n"
          reply_text << "・名古屋市西区砂原町\n「砂原町」または「すなはら」\n\n"
          reply_text << "・名古屋市西区浅間一丁目\n「浅間1」または「浅間一」\n\n"
          reply_text << "・名古屋市西区浅間二丁目\n「浅間2」または「浅間二」\n"
          
        when /.*(数奇屋|すきや).*/
          reply_text =  GarbageDateSuk.notice_message
        when /.*(砂原町|すなはら).*/
          reply_text =  GarbageDateSun.notice_message
        when /.*(浅間1|浅間一).*/
          reply_text =  GarbageDateSen1.notice_message
        when /.*(浅間2|浅間二).*/
          reply_text =  GarbageDateSen2.notice_message
        end
      when Line::Bot::Event::MessageType::Location
        # 位置情報が入力された場合
        
        # 位置情報を取得
        latitude = event.message['latitude']
        longitude = event.message['longitude']
        puts "位置情報を取得しました！"
        pref, area = $db.set_weather_location(user_id, latitude, longitude)
        reply_text = %{天気の地域を#{pref} #{area}にセットしました！}
        reply_text << %{\n\n「天気」と入力すると、現在設定されている地域の天気をお知らせします。}
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
