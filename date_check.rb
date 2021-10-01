class DateChecker
  def self.nth_day_of_week(now: Time.now)
    # 曜日を定義
    wdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 =>"土"}

    # 第何回目かを定義
    nth = (now.day + 1) / 8 + 1

    # 第何回目かと翌日の曜日を返す
    return {nth: nth, wday: wdays[now.wday + 1]}
  end
end

datechecker = DateChecker.new
puts DateChecker.nth_day_of_week