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

  

