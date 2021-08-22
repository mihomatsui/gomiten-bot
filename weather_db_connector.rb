require 'active_record'
require 'dotenv/load'

class WeatherDbConnector
  # 環境変数を使って接続する
  ActiveRecord::Base.establish_connection(
    adapter: ENV['myadapter'],
    host:    "",
    username: ENV['myusername'],
    password: ENV['mypassword'],
    database: ENV['mydatabase']
  )

  # クラスを作成
  class Weather < ActiveRecord::Base
  end

  def set_location(user_id, latitude, longitude)
    p 'set_location'
    # 絶対値格納用のカラムを追加
    addsql = 'ALTER TABLE weathers ADD COLUMN abs decimal;'
    ActiveRecord::Base.connection.execute(addsql)

    # 緯度経度を計算して絶対値を取得する
    calculatepoint = '(latitude - #{latitude}) + (longitude - #{longitude}'
    calculatepoint_abs = abs(calculatepoint)
    # 計算結果を挿入して検索
    insertsql = 'insert into weathers (abs) values (calculatepoint_abs);'
    searchsql = 'select * from weathers order by abs[asc].first'
    result = ActiveRecord::Base.connection.select_all(searchsql).to_hash
    
    # 結果を取得
    puts %{#{result['id']},#{result['pref']},#{result['area']},#{result['latitude']}, #{result['longitude']}}
    return result["pref"], result["area"]

    # 絶対値格納用のカラムを削除
    # deletesql = 'ALTER TABLE weathers DROP COLUMN abs numeric;'
    # ActiveRecord::Base.connection.execute(deletesql)
  end
end