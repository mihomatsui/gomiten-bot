require 'active_support'
require 'active_support/core_ext'
class GarbageDate
  attr_reader :wday, :nth, :type
  # 曜日
  WDAYS = %w(日 月 火 水 木 金 土).freeze

  def initialize(wday:, nth:, type:)
    @wday = WDAYS.index(wday)
    @nth = nth
    @type = type
  end

  def to_s
    "第 #{nth} #{WDAYS[wday]}曜日「#{type}」"
  end

  def apply?(date)
    wday == date.wday && nth == nth_day_of_week(date)
  end

  private

  # 日付がその月で何回目の曜日なのか
  def nth_day_of_week(date)
    (date.beginning_of_month..date).count { _1.wday == date.wday }
  end
end  

GARBAGE_DISPOSAL_DAYS = [
  # 毎週火・金は可燃ごみの日
  *%w(火 金).product([*1..5]).map { |wday, nth| GarbageDate.new(wday: wday, nth: nth, type: '可燃ゴミ')},
  GarbageDate.new(wday: '水', nth: 4, type: '不燃ゴミ'),
  GarbageDate.new(wday: '木', nth: 4, type: 'プラスチックゴミ'),
  GarbageDate.new(wday: '木', nth: 4, type: '缶・ビン・ペットボトル')
]
tomorrow = Date.tomorrow
garbage_disposal_day = GARBAGE_DISPOSAL_DAYS.find {_1.apply?(tomorrow)}

# def message_check
#   message = case check
#   when garbage_disposal_day then '#{garbage_disposal_day}の日です'
#   else '特に出せるゴミはありません'
#   end
#    puts "明日(#{tomorrow.strftime("%m月%d日")})は#{message}"
# end
message = ''
message << %{明日(#{tomorrow.strftime("%m月%d日")})は}
if garbage_disposal_day
  message << %{#{garbage_disposal_day}の日です}
else 
  message << %{特に出せるゴミはありません}
end
puts message
