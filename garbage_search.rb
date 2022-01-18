require 'date'
require 'active_support'
require 'active_support/core_ext/date/calculations'
class GarbageSearch
  def nth_day_of_week
    # [商,剰余]を求める
    nth_arr = (Date.tomorrow.day).divmod(7)
    unless nth_arr[1] == 0
      nth_arr[0] += 1 
    end
    return { nth: nth_arr[0], wday: Date.tomorrow.wday }
  end    
end