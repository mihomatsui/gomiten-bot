require 'net/http'
require 'uri'
require 'rexml/document'

# 北海道上川地方の今日の天気を取得する場合
# weather = WeatherInfoConnector.new('北海道', '上川地方', 'http://www.drk7.jp/weather/xml/01.xml', 'weatherforecast/pref/area[1]', 0)

# 天気情報の取得
weather = WeatherInfoConnector.new(pref, area, url, xpath, set_day)
puts weather.WeatherInfoConnector

class WeatherInfoConnector
  def get_weatherinfo
    # URIをparse(解析)
    uri = URI.parse(url)
    # ウェブサーバからドキュメントを得る (GET)
    xml = Net::HTTP.get(uri)
    # XMLを指定したインスタンスを作成してDOMツリーを構築
    doc = REXML::Document.new(xml)
 
    # 各情報を取得
    case set_day
    when 0
      fix_xpath = xpath + '/info[1]' #今日
    when 1
      fix_xpath = xpath + '/info[2]' #明日
    when 2
      fix_xpath = xpath + "/info[3]" #明後日
    else
      fix_xpath = xpath + "/info[0]" #今日
    end
  end
  
end
