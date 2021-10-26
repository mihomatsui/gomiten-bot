require 'net/http'

Net::HTTP.version_1_2
http = Net::HTTP.new("gomiten-bot-staging.herokuapp.com", 443)
http.use_ssl = true
response = http.post('/send', 'msg=forecast')

case forecast
when /.*(雨|雪).*/ 
  message_sticker = {"type": "sticker", "packageId": "446", "stickerId": "1994"}
  messages = [message, message_sticker]
  p client.push_message(row['user_id'], messages)
else
  p client.push_message(row['user_id'], message)
end  