class Date
  # 第n週目
  def nweek
    (self.day + 6 + (self - self.day + 1).wday) / 7
  end

  def self.tomorrow
    self.today + 1
  end
end