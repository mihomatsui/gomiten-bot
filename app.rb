require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './weather_db_connector.rb'
require './weather_info_connector.rb'



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