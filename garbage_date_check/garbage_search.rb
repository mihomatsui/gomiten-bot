class GarbageSearch
  require 'date'
  require 'active_support/all'

  def nth_day_of_week(now: Time.current)
    wdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土" }
    # 月初と現在が同じ週だった場合に1としたいので、月の最初の週は0とするためcweekから1を引く
    beginning_of_month_cweek = now.beginning_of_month.to_date.cweek - 1
    nth = now.to_date.cweek - beginning_of_month_cweek
    # 年跨ぎの場合、nthが上記方針だとマイナスになるケースがあるので、その場合は前週の結果に+1する方針とする
    # 例) "2019/12/31".in_time_zone.to_date.cweek => 1, "2019/12/1".in_time_zone.to_date.cweek => 48
    nth = now.ago(1.week).to_date.cweek - beginning_of_month_cweek if nth.negative?
    return { nth: nth, wday: wdays[now.wday] }
  end    
end

search_day = GarbageSearch.new
p search_day.nth_day_of_week(now: Time.current.tomorrow) # =>{:nth=>3, :wday=>"水"}