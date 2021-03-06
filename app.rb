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
require './garbage_search'

helpers ApplicationHelper
get '/' do
  erb :top
end

$db = WeatherDbConnector.new
$search = GarbageSearch.new

helpers do
  def protected!
    return if authorized?
    headers["WWW-Authenticate"] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials ==[ENV["BASIC_AUTH_USERNAME"], ENV["BASIC_AUTH_PASSWORD"]]
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
    forecast = weather_info_conn.get_weatherinfo(row["pref"], row["area"], row["url"].sub(/http/, "https"), row["xpath"], set_day)
    puts forecast
    message = { type: "text", text: forecast }
  
    case forecast
    when /.*(雨|雪).*/ 
      message_sticker = {"type": "sticker", "packageId": "446", "stickerId": "1994"}
      messages = [message, message_sticker]
        
      p client.push_message(row["user_id"], messages)
    else
      p client.push_message(row["user_id"], message)
    end
  end
  rescue => e
    p e
  end
  puts "done."
end

post '/callback' do
  body = request.body.read
  signature = request.env["HTTP_X_LINE_SIGNATURE"]
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end
  events = client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      user_id = event["source"]["userId"]
      reply_text = "使い方:\n\n・位置情報を送信してください。\n(トークルーム下部の「+」をタップして、「位置情報」から送信できます。)\n\n"
      reply_text << "・毎日朝7時に天気をお知らせします。\n"
      reply_text << "・通知が多い場合はトーク画面右上から設定を変更してください。\n\n"
      reply_text << "・「天気」と入力すると、現在設定されている地域の天気をお知らせします。\n"
      
      case event.type
      when Line::Bot::Event::MessageType::Text
        # 文字列が入力された場合
        case event.message["text"]
        when /.*(天気|てんき).*/
          weather_info_conn = WeatherInfoConnector.new
          begin
            info = $db.get_notifications(user_id)
            reply_text = weather_info_conn.get_weatherinfo(info["pref"], info["area"], info["url"].sub(/http/, "https"), info["xpath"], set_day = 0)
          rescue => e
            reply_text = weather_info_conn.get_weatherinfo("愛知県", "西部", "https://www.drk7.jp/weather/xml/23.xml", "weatherforecast/pref/area[2]", set_day = 0) #名古屋駅
            p e
          end
        when /.*(明日|あした).*/
          weather_info_conn = WeatherInfoConnector.new
          begin
            info = $db.get_notifications(user_id)
            reply_text = weather_info_conn.get_weatherinfo(info["pref"], info["area"], info["url"].sub(/http/, "https"), info["xpath"], set_day = 1)
          rescue => e
            reply_text = weather_info_conn.get_weatherinfo("愛知県", "西部", "https://www.drk7.jp/weather/xml/23.xml", "weatherforecast/pref/area[2]", set_day = 1) 
            p e
          end
        when /.*(明後日|あさって).*/
          weather_info_conn = WeatherInfoConnector.new
          begin
            info = $db.get_notifications(user_id)
            reply_text = weather_info_conn.get_weatherinfo(info["pref"], info["area"], info["url"].sub(/http/, "https"), info["xpath"], set_day = 2)
          rescue => e
            reply_text = weather_info_conn.get_weatherinfo("愛知県", "西部", "https://www.drk7.jp/weather/xml/23.xml", "weatherforecast/pref/area[2]", set_day = 2) 
            p e
          end  
        
        when /.*(ゴミテン|ごみてん).*/
          reply_text = "gomitenとは:\n\n・ゴミテンと読みます。ゴミの収集日と天気予報をお知らせします。\n\n"
          reply_text << "・天気予報は位置情報を送信していない場合、"
          reply_text << "愛知県西部の天気予報をお知らせします。\n"
          reply_text << "・ゴミの収集日は地域を入力すると返信でお知らせします。\n"
          reply_text << "・対象地域は「ゴミの収集日」でご確認ください。\n"
        when /.*(ゴミ|ごみ).*/
          reply_text = "使い方:\n\n・明日のゴミの収集日をお知らせします。\n・該当地域の数字を半角で入力してください。\n\n"
          reply_text << "＜対応地域一覧＞\n"
          reply_text << "1.名古屋市西区数奇屋\n"
          reply_text << "2.名古屋市西区砂原町\n"
          reply_text << "3.名古屋市西区浅間一丁目\n"
          reply_text << "4.名古屋市西区浅間二丁目\n"
          
        when /.*(1).*/
          $search = GarbageSearch.new
          # 週と曜日を取得
          tomorrow = $search.nth_day_of_week
          nth = tomorrow[:nth]
          wday = tomorrow[:wday]
          garbage_area_id = 1
          reply_text = $db.get_garbages(garbage_area_id, wday, nth)
        when /.*(2).*/
          $search = GarbageSearch.new
          tomorrow = $search.nth_day_of_week
          nth = tomorrow[:nth]
          wday = tomorrow[:wday]
          garbage_area_id = 2
          reply_text = $db.get_garbages(garbage_area_id, wday, nth)
        when /.*(3).*/
          $search = GarbageSearch.new
          tomorrow = $search.nth_day_of_week
          nth = tomorrow[:nth]
          wday = tomorrow[:wday]
          garbage_area_id = 3
          reply_text = $db.get_garbages(garbage_area_id, wday, nth)
        when /.*(4).*/
          $search = GarbageSearch.new
          tomorrow = $search.nth_day_of_week
          nth = tomorrow[:nth]
          wday = tomorrow[:wday]
          garbage_area_id = 4
          reply_text = $db.get_garbages(garbage_area_id, wday, nth)
        end
      when Line::Bot::Event::MessageType::Location
        # 位置情報が入力された場合
        
        # 位置情報を取得
        latitude = event.message["latitude"]
        longitude = event.message["longitude"]
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
