# 制作背景
サービスの概要は、LINEをプラットフォームにゴミの収集日と天気予報を確認できるアプリです。<br>
想定しているユーザーとしては、ゴミの収集日がなかなか覚えられない人や朝に天気予報を確認する人を想定しています。<br>
「調べたら良いんだけど、朝は忙しい。LINEで通知が決まった時間に飛んできたら便利だよなぁ」と思ったため制作しました。<br>
解決したい課題として、ゴミの出し忘れを防ぐこと。また、天気予報を見ずに外出し、傘やタオルを購入したり、<br>
自転車で雨に降られ体調不良になることへの解決を目指して作りました。

## URL
- URL (サイトトップページ）: https://gomiten-bot.herokuapp.com
- アプリの使い方や特徴を紹介しています。
![heroku_toppage640](https://user-images.githubusercontent.com/70443334/140608759-3aa1b7ec-8a22-46ed-9809-7965bca3131f.gif)
- アプリアイコン
<img  width="300" src="https://user-images.githubusercontent.com/70443334/140645618-44e98907-4dab-4dba-8133-f6f2816ef0e4.png">

- LINEの友達追加用のQRコード
- LINEの画面からQRコードを読み込み、友達追加をすると操作ができます。
<img width="200" src="https://user-images.githubusercontent.com/70443334/140516491-61f21163-9b1d-4158-af74-381c36bb0025.png">

## ER図
<img width="700" alt="er図" src="https://user-images.githubusercontent.com/70443334/140643883-b77735c9-73f9-44b0-874c-d2b72d1c0595.png">

## 使用技術
- 言語：Ruby(2.7.3)
- フレームワーク：Sinatra(2.1.0)
- フロントエンド：HTML&CSS/Bootstrap
- DB：PostgreSQL
- インフラ：Heroku(ステージング環境→本番環境)
- ソースコード管理：GitHub(Projectsのカンバン方式でタスクを管理)
- その他(使用ツール、素材など)
  - LINEMessagingAPI
  - ngrok(2.3.40)(ローカルでの動作確認)
  - Japan Weather Forecast(天気情報の取得)
  - cron-job.org(httpリクエストを定時実行→LINEに通知)
  - FontAwesome
  - Visual Studio
  - draw.io
  - unDraw(イラスト素材)
  - material design palette(カラーパレットツール)
  - canva(リッチメニューデザイン)
  - ロゴメーカー/STORES(ロゴ)
  - ICOOON MONO(アイコン)

# 機能一覧

## 1.リッチメニューとテキストから、全国の天気予報が取得可能
- 位置情報を送信すると、地方が設定されます。
- 今日・明日・明後日の3日間の情報取得が可能です。
- 下記の動画では、位置情報を送信して、リッチメニューの`今日の天気→明日の天気→明後日の天気`を順に操作しています。

<img width="700" alt="天気動作確認" src="https://user-images.githubusercontent.com/70443334/140679886-cccf4588-3437-49a7-bec8-a1c3ca655596.gif">
  
### 工夫点
①LINEの公式ドキュメントを読み、リッチメニューを実装しました。

②雪の天気の時は傘が必要であることを考慮して、スタンプが送信されるよう実装しました。

<img width="300" alt="rainstamp.png" src="https://user-images.githubusercontent.com/70443334/140666098-15b2e019-2eb1-408f-8ab5-912573131f06.png">


③天気・気温・6時間ごとの降水確率が取得できるAPIを使用しました。<br>

気象庁が発表している天気予報情報を、XML形式にしたデータを使わせていただきました。（https://www.drk7.jp/weather/）

<img width="681" alt="API_XML" src="https://user-images.githubusercontent.com/70443334/140681687-ad4423c7-2da8-480f-9690-a1ef492c1977.png">

  
## 2.毎朝7時に天気予報がLINEの通知で届く
- 「LINEで通知が決まった時間に飛んできたら便利だよなぁ」という欲求の解決のため、実装しました。
  
### 工夫点
①httpリクエスト時にセキュリティ(basic認証)を設定し、外部の不正な情報の侵入を防ぐ対策をしました。<br>

webページにアクセスしようとすると、ユーザー名とパスワードの入力が求められます。<br>
※staging環境のURLとなっていますが、本番環境も同様の表示がされます。


<img width="697" alt="basic認証" src="https://user-images.githubusercontent.com/70443334/140727080-f0c7cf8e-c2a4-4227-89b4-2cb9616c218a.png">

```    
helpers do
  def protected!
    return if authorized?
    headers["WWW-Authenticate"] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials ==[ENV["BASIC_AUTH_USERNAME"], ENV["BASIC_AUTH_PASSWORD"]]
  end
end
```

<br>
②cron-jobを採用し、決まった時間に送信ができるようにしました。（heroku schedulerは数分の誤差が発生）<br>

7時に/sendアクションが実行されるように設定しています。<br>
  

<img width="800" alt="cron-job org" src="https://user-images.githubusercontent.com/70443334/140728833-86184db6-3c71-443b-b73e-9507ada5cc20.png">
<br>

```Ruby
get '/send' do 
  protected! #basic認証
  weather_info_conn = WeatherInfoConnector.new
  begin
  $db.get_all_notifications.each do |row|
    set_day = 0 # weatherapiは朝6時に更新 0は当日
    forecast = weather_info_conn.get_weatherinfo(row["pref"], row["area"], row["url"].sub(/http/, "https"), row["xpath"], set_day)
    puts forecast
    message = { type: "text", text: forecast }
    p "push message"

    case forecast
    when /.*(雨|雪).*/ # 天気が雨または雪のときはスタンプも送信
      message_sticker = {"type": "sticker", "packageId": "446", "stickerId": "1994"}
      messages = [message, message_sticker] 
        
      p client.push_message(row["user_id"], messages)
    else
      p client.push_message(row["user_id"], message)
    end
  end
  rescue => e
    p e
  end
  puts "done."
end
```
<br>
<img width="400" alt="7時に届く様子の画像" src="https://user-images.githubusercontent.com/70443334/140731024-984aabba-47b3-4a60-92f5-ad4b46f651dc.png">


## 3.テキストから、翌日のゴミの収集日が取得可能
- 地域名を入力して送信すると、翌日のゴミの収集日が返信されます。
- 現在、愛知県名古屋市の一部の地区に対応しています。 
- 対象地域：名古屋市西区数奇屋、名古屋市西区砂原町、名古屋市西区浅間一丁目、名古屋市西区浅間二丁目
  
### 工夫点
①隔週の収集日にも対応できるよう、日付・曜日・週のデータを使用して実装しました。

②ひらがなと漢字のどちらを入力しても、返信が来るようにしています。

（例）名古屋市西区数奇屋　→ 数奇屋 または　すきや
  
<img width="700" alt="ゴミの収集日のgif" src="https://user-images.githubusercontent.com/70443334/140738799-2c27e215-3adc-42d3-bf48-35ad21f4e4cc.gif">

# 工夫したところ

## 1.チーム開発を意識

実務でのチーム開発を想定した開発を行いました。

① Git、GitHubを用いたソース管理

② Projectsのカンバン方式でタスクを管理

③ ブランチ運用は、ブランチの運用のミスを軽減できる点や複数人でのチーム開発を想定してGitflowを採用

④ こまめにcommitし、プルリクエストを出しマージする流れで開発

| ブランチ名 | 目的 | 備考 |
| :--- | :--- | :--- |
| main | 本番用 | 本番リリース用のブランチ |
| develop | 開発用 | 機能実装用のブランチはここから切る |
| feature | 機能実装用 | 派生元はdevelopブランチ |

## 2.UI/UX

### サイトトップページ
- サイトトップページは、元気や明るさをイメージしてオレンジをメインカラーに設定しています。
- 配色は下記を参考に行い、統一感を出すように工夫しました。

<img width="500" alt="タウンワーク風" src="https://user-images.githubusercontent.com/70443334/140649941-537f947d-34fc-47c1-909b-a7d6c389129b.png">

### リッチメニュー
- 太陽をイメージする赤をメインカラーに設定しています。

<img width="500" alt="リッチメニュー" src="https://user-images.githubusercontent.com/70443334/140650015-7a4c963f-349c-4e6d-a769-46ff72c425bf.jpg">

## 3. インプットしながらアウトプット
- フレームワークはSinatraを選択しました。
- 公式ドキュメントを中心に、ヘルパーメソッドやbasic認証機能などを学習しながらアプリ制作を行いました。

### Sinatraを選択した理由
- Ruby on Railsを使わず、なるべくRubyのみで作成したいと考えたため
- 学習コストが低く習得しやすいと考えたため
- 小規模なアプリケーションに向いているため
