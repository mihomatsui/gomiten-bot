require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
Dotenv.load
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
  puts("----A----")
  puts(body)
  puts("----B----")
  print(signature)
  puts("----C----")
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end
  events = client.parse_events_from(body)
  events.each do |event|
    if event.is_a?(Line::Bot::Event::Message)
      if event.type === Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: event.message['text']
        }
        client.reply_message(event['replyToken'], message)
        
      end
    end    
  end
  "OK"
end
get '/' do
  "Hello world!"
end