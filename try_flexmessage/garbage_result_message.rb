require './garbage_date_check/sukiya'
require './garbage_date_check/sunahara'
require './garbage_date_check/sengen1'
require './garbage_date_check/sengen2'

module LineBot
  module Messages
    class GarbageResultMessage
      include LineBot::Messages::Concern::Carouselable

      def send(data)
        garbage_hash = { sukiya: '数奇屋', sunahara: '砂原町', sengen1: '浅間1', sengen2: '浅間2'}
        # to_symでシンボルに変換
        result = garbage_hash[data['result'].to_sym]
        
        case result
        when ['数奇屋']
          { 
            type: 'text', 
            text: GarbageDateSuk.notice_message
          }
        when ['砂原町']
          { 
            type: 'text', 
            text: GarbageDateSun.notice_message
          }
        when ['浅間1']
          { 
            type: 'text', 
            text: GarbageDateSen1.notice_message
          }
        when ['浅間2']
          { 
            type: 'text', 
            text: GarbageDateSen2.notice_message
          }
        end
      end
    end
  end
end