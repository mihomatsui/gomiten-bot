require 'net/http'
require 'uri'
require 'rexml/document'

# 北海道上川地方の今日の天気を取得する場合
# weather = WeatherInfoConnector.new('北海道', '上川地方', 'http://www.drk7.jp/weather/xml/01.xml', 'weatherforecast/pref/area[1]', 0)

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
      fix_xpath = xpath + '/info[1]' #今日
    when 1
      fix_xpath = xpath + '/info[2]' #明日
    when 2
      fix_xpath = xpath + '/info[3]' #明後日
    else
      fix_xpath = xpath + '/info[0]' #今日
    end

    date = doc.elements['fix_xpath'].attributes['date'] #日時
    weather = doc.elements['fix_xpath' + '/weather'].text  #天気
    max = doc.elements['fix_xpath' + '/temperature/range[1]'].text #最高温
    min = doc.elements['fix_xpath' + '/temperature/range[2]'].text #最低気温
    per00to06 = doc.elements['fix_xpath' + '/rainfallchance/period[1]'].text  #降水確率
    per06to12 = doc.elements['fix_xpath' + '/rainfallchance/period[2]'].text
    per12to18 = doc.elements['fix_xpath' + '/rainfallchance/period[3]'].text
    per18to24 = doc.elements['fix_xpath' + '/rainfallchance/period[4]'].text
    text00to06 = doc.elements['fix_xpath' + "/rainfallchance/period[1]"].attributes['hour'] #メッセージ送信で"00-06"を使用するためテキストを取得
    text06to12 = doc.elements["fix_xpath" + "/rainfallchance/period[2]"].attributes["hour"]
    text12to18 = doc.elements["fix_xpath" + "/rainfallchance/period[3]"].attributes["hour"]
    text18to24 = doc.elements["fix_xpath" + "/rainfallchance/period[4]"].attributes["hour"]
  end  
end
