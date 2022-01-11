class GarbageSearch
  require 'date'
  require 'active_support/all'

  def nth_day_of_week
    wdays = { 0 => "日", 1 => "月", 2 => "火", 3 => "水", 4 => "木", 5 => "金", 6 => "土" }
    
    # [商,剰余]を求める
    p nth_arr = (Date.tomorrow.day).divmod(7)
    unless nth_arr[1] == 0
      nth_arr[0] += 1 
    end
    return { nth: nth_arr[0], wday: wdays[Date.tomorrow.wday] }
  end    
end

search = GarbageSearch.new
p search.nth_day_of_week