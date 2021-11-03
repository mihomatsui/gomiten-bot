class Date
  def mweek
    (self.day + 6 + (self - self.day + 1).wday) / 7
  end

  def self.tomorrow
    self.today + 1
  end  
end