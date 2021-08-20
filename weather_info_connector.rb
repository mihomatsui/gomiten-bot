require 'net/http'
require 'uri'
require 'rexml/document'

# 愛知県西部の今日の天気を取得する場合
# weather = WeatherInfoConnector.new('愛知県', '西部', 'http://www.drk7.jp/weather/xml/23.xml', 'weatherforecast/pref/area[2]', 0)

class WeatherInfoConnector
  def get_weatherinfo
    # URIをparse(解析)
    uri = URI.parse(url)
    # ウェブサーバからドキュメントを得る (GET)
    xml = Net::HTTP.get(uri)
    # XMLを指定したインスタンスを作成してDOMツリーを構築
    doc = REXML::Document.new(xml)
 
    # 各情報を取得

    # どの日にちのデータを取得するか
    case set_day
    when 0
      fix_xpath = xpath + '/info[1]' # 今日
    when 1
      fix_xpath = xpath + '/info[2]' # 明日
    when 2
      fix_xpath = xpath + '/info[3]' # 明後日
    else
      fix_xpath = xpath + '/info[0]' # 今日
    end

    date = doc.elements['fix_xpath'].attributes['date'] # 日時
    weather = doc.elements['fix_xpath' + '/weather'].text  # 天気
    max = doc.elements['fix_xpath' + '/temperature/range[1]'].text # 最高温
    min = doc.elements['fix_xpath' + '/temperature/range[2]'].text # 最低気温
    # 降水確率
    per00to06 = doc.elements['fix_xpath' + '/rainfallchance/period[1]'].text  
    per06to12 = doc.elements['fix_xpath' + '/rainfallchance/period[2]'].text
    per12to18 = doc.elements['fix_xpath' + '/rainfallchance/period[3]'].text
    per18to24 = doc.elements['fix_xpath' + '/rainfallchance/period[4]'].text
    # メッセージ送信で使用するためテキストを取得
    text00to06 = doc.elements['fix_xpath' + "/rainfallchance/period[1]"].attributes['hour'] 
    text06to12 = doc.elements["fix_xpath" + "/rainfallchance/period[2]"].attributes["hour"]
    text12to18 = doc.elements["fix_xpath" + "/rainfallchance/period[3]"].attributes["hour"]
    text18to24 = doc.elements["fix_xpath" + "/rainfallchance/period[4]"].attributes["hour"]
  end  

  # Botでメッセージを表示する
  message = ''
  message << %{#{pref} #{area} の#{date} の天気は #{weather}\n\n}
  message << %{最高気温 #{max}\n}
  message << %{最低気温 #{min}\n\n}
  message << %{降水確率 #{text00to06}:#{per00to06}%,#{text06to12}:#{per06to12}%,#{text12to18}:#{per12to18}%,#{text18to24}:#{per18to24}%}
  return message
end
