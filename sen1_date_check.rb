require "active_support"
require "active_support/core_ext"

# 西区浅間一丁目のゴミ収集日のデータ
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

  GARBAGE_DISPOSAL_DAYS = [
  # 毎週月・木は可燃ごみの日
    *%w(月 木).product([*1..5]).map { |wday, nth| GarbageDate.new(wday: wday, nth: nth, type: '可燃ゴミ')},
    GarbageDate.new(wday: '水', nth: 4, type: '不燃ゴミ'),
    *%w(金).product([*1..5]).map { |wday, nth| GarbageDate.new(wday: wday, nth: nth, type: 'プラスチックゴミ')},
    *%w(水).product([*1..5]).map { |wday, nth| GarbageDate.new(wday: wday, nth: nth, type: '缶・ビン・ペットボトル')}
  ]
  tomorrow = Date.tomorrow
  garbage_disposal_day = GARBAGE_DISPOSAL_DAYS.find {_1.apply?(tomorrow)}

  message = ''
  message << %{明日(#{tomorrow.strftime("%m月%d日")})は}
  if garbage_disposal_day
    message << %{#{garbage_disposal_day}の日です}
  else 
    message << %{特に出せるゴミはありません}
  end
  puts message
end