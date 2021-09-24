require "csv"
# insert文を生成
reader = CSV.open("index-select-ken-all.csv", "r")
reader.shift

sql = "insert into addresses (id, postalcode, pref, municipalities, townarea) values \n"
reader.each do |line|
  id = line[0].to_s
  postalcode = line[1].to_s
  pref = line[2].to_s
  municipalities = line[3].to_s
  townarea = line[4].to_s
  insertValue =
    "(" + id + ", " + postalcode + ",'" + pref + "','" + municipalities + "','" + townarea + "'),\n"
  sql += insertValue
end

# SQLを出力
File.open("insert_addresses.sql", "w") { |f|
  f.write sql
}
