require 'date'
require_relative 'date_check'

class Sengen2Chome
  #ゴミ出し日を定義する
  GARBAGE_DISPOSAL_DAYS = [
    # 毎週火・金は可燃ごみの日
    *%w(火 金).product([*1..5]).map { |wday, nth| GarbageDate.new(wday: wday, nth: nth, type: '可燃ゴミ')},
    GarbageDate.new(wday: '水', nth: 4, type: '不燃ゴミ'),
    GarbageDate.new(wday: '木', nth: 4, type: 'プラスチックゴミ'),
    GarbageDate.new(wday: '木', nth: 4, type: '缶・ビン・ペットボトル')
  ]

  tomorrow = Date.tomorrow
  garbage_disposal_day = GARBAGE_DISPOSAL_DAYS.find {_1.apply?(tomorrow)}

  message = ''
  message << %{明日(#{tomorrow.strftime("%m月％d日 %a")})は}
  if garbage_disposal_day
  message << %{#{garbage_disposal_day}の日です}
  else 
    message << %{特に出せるゴミはありません}
  end
  return message
end
