class Date
  # 第n週目
  def nweek
    now.day / 8 + 1
  end

  def self.tomorrow
    self.today + 1
  end
end

