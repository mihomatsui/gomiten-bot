require 'net/http'
require 'uri'
require 'rexml/document'

uri = URI.parse("http://www.drk7.jp/weather/xml/01.xml")
response = Net::HTTP.get_response(uri)
p response.code
p response.body

# サイトからxmlファイルを持ってくる
# xmlファイルから必要な項目を取り出す