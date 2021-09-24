#addressesテーブル用のcsvファイルを準備
require "csv"

#英語のヘッダーを定義
header = ["prefcode", "pref", "municipalities_code", "municipalities", "townblock_code", "townblock", "latitude", "longitude", "document_code", "townblock_sortcode"]

# 元々の日本語のヘッダー（データの一行目）を削除
data = CSV.foreach("address.csv")
deleted_data = CSV.read("address.csv").flatten[0]

# CSVデータを生成する
CSV.open('head-address.csv','w') do |csv|
  csv << header #ヘッダ行をCSVに追加
  data.each do |d|
    csv << d unless deleted_data.include?(d.first)
  end
end

# 一部のデータだけ抜き出す
COLS = [1, 2, 4, *(6..8)].map { |x| x - 1 }
CSV.open("select-address.csv", "w") do |out|
  CSV.foreach("head-address.csv") do |row|
    out << row.values_at(*COLS)
  end
end

# ヘッダーを置換してidを挿入する
tbl = CSV.table("select-address.csv",
                header_converters: lambda { |h|
                  h == "prefcode" ? "id" : h
                },
                :converters => nil)
tbl.each_with_index { |row, i| row["id"] = i }
file_path = "insert-id-address.csv"
File.open(file_path, "wb") { |f| f.puts(tbl.to_csv) }
