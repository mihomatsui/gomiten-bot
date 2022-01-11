class GarbageSearch
  require 'date'
  require 'active_support/all'

  def nth_day_of_week(now: Time.current.tomorrow)
    wdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土" }
    
    beginning_of_month_cweek = now.beginning_of_month.to_date.cweek - 1 
    now.to_date.cweek
    nth = now.to_date.cweek - beginning_of_month_cweek
  

    p now.ago(1.week).to_date.cweek
    nth = now.ago(1.week).to_date.cweek - beginning_of_month_cweek if nth.negative?
    return { nth: nth, wday: wdays[now.wday] }
  end    
end

search = GarbageSearch.new
p search.nth_day_of_week