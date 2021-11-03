require 'uri'

# ポストバックイベント
# Flexmessageのポストバックアクションを実行したときの動き

module LineBot
  class PostbackEvent
    def self.send(data)
      # 他の形式へ変換したデータを戻す
      data = URI.decode_www_form(data).to_h
    end

    case data['type']
    when 'none'
      # 何もしない
    when 'garbage_result'
      LineBot::Messages::GarbageResultMessage.new.send(data)
    end
  end
end