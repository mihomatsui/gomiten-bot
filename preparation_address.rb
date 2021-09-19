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
  p row.to_h
end
