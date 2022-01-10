class GarbageSearch
  require 'date'
  require 'active_support/all'

  def nth_day_of_week(now: Time.current.tomorrow)
    wdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土" }
    # 月初と現在が同じ週だった場合に1としたいので、月の最初の週は0とするためcweekから1を引く
   #now.beginning_of_month # => 2022-01-01 00:00:00 +0900
   #now.beginning_of_month.to_date # => Sat, 01 Jan 2022
    beginning_of_month_cweek = now.beginning_of_month.to_date.cweek - 1 #=> 52-1=51
    now.to_date.cweek #=> 2
    nth = now.to_date.cweek - beginning_of_month_cweek #=> 2-51=-49
  

    # 年跨ぎの場合、nthが上記方針だとマイナスになるケースがあるので、その場合は前週の結果に+1する方針とする
    p now.ago(1.week).to_date.cweek #=> 1
    nth = now.ago(1.week).to_date.cweek - beginning_of_month_cweek if nth.negative? #=> 1-51 = -50
    return { nth: nth, wday: wdays[now.wday] }
  end    
end

search = GarbageSearch.new
p search.nth_day_of_week  #=>{:nth=>-50, :wday=>"火"}