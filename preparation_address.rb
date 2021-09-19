require 'csv'
CSV.foreach("x-ken-all.csv") do |row|
  # 行に対する処理
  p row
end
