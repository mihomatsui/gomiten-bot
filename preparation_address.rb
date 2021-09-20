require 'csv'
header = ["government_code", "old_postalcode", "postalcode", "kana_pref", "kana_municipalities", "kana_townarea", "pref", "municipalities", "townarea", "multiple_postalcode", "koaza_townarea", "city_block", "multiple_townarea", "update", "update_reason"]

data = CSV.foreach("x-ken-all.csv")

# CSVデータを生成する
CSV.open('head-x-ken-all.csv','w') do |csv|
  csv << header #ヘッダ行をCSVに追加
  data.each do |d|
    csv << d #データ行をCSVに追加
  end
end

# 生成したCSVデータを読み込む
# CSV.foreachの引数にheaders: trueとつけて先頭行をヘッダとして認識する
CSV.foreach("head-x-ken-all.csv", headers: true) do |row|
  #p row.to_h
end

# 一部のデータだけ抜き出す
COLS=[1,3,*(7..9)].map{|x| x-1}
CSV.open("select-ken-all.csv","w") do |out|
  CSV.foreach("head-x-ken-all.csv")  do |row|
    out << row.values_at(*COLS)
  end
end

# ヘッダーを置換してidを挿入する
tbl = CSV.table('select-ken-all.csv', 
  header_converters: lambda {|h| 
    h == 'government_code' ? 'id' : h
})
tbl.each_with_index{|row, i| row['id'] = i}
file_path = 'index-select-ken-all.csv'
File.open(file_path, 'wb') {|f| f.puts(tbl.to_csv)}