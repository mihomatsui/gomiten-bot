require "csv"
# insert文を生成
reader = CSV.open("insert_id_address.csv", "r")
reader.shift

sql = "insert into addresses (id, pref, municipalities, townblock, latitude, longitude) values \n"
reader.each do |line|
  id = line[0].to_s
  pref = line[1].to_s
  municipalities = line[2].to_s
  townblock = line[3].to_s
  latitude = line[4].to_s
  longitude = line[5].to_s
  insertValue =
    "(" + id + ", '" + pref + "','" + municipalities + "','" + townblock + "'," + latitude + "," + longitude + "),\n"
  sql += insertValue
end

# SQLを出力
File.open("insert_addresses.sql", "w") { |f|
  f.write sql
}
