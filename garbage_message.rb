class GarbageMessage
  include LineBot::Messages::Concern::Carouselable
  def send
    carousel('alter_text', [bubble])
  end

  def bubble
    {
  "type": "carousel",
  "contents": [
    {
      "type": "bubble",
      "size": "micro",
      "body": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "text",
            "text": "収集地域「名古屋市西区：す行」",
            "weight": "bold",
            "size": "sm",
            "wrap": true,
            "decoration": "none"
          },
          {
            "type": "box",
            "layout": "baseline",
            "contents": []
          },
          {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "box",
                "layout": "baseline",
                "spacing": "sm",
                "contents": [
                  {
                    "type": "text",
                    "text": "表示したい地域を選択してください",
                    "wrap": true,
                    "color": "#444444",
                    "size": "xs",
                    "flex": 5
                  }
                ]
              }
            ]
          }
        ],
        "spacing": "sm",
        "paddingAll": "13px",
        "backgroundColor": "#FFC60B"
      },
      "footer": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "button",
            "action": {
              "type": "postback",
              "label": "数奇屋町",
              "data": "数奇屋町",
              "displayText": "数奇屋町"
            },
            "height": "sm",
            "color": "#757575"
          },
          {
            "type": "button",
            "action": {
              "type": "postback",
              "label": "砂原町",
              "data": "砂原町",
              "displayText": "砂原町"
            },
            "height": "sm",
            "color": "#757575"
          }
        ]
      }
    },
    {
      "type": "bubble",
      "size": "micro",
      "body": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "text",
            "text": "収集地域「名古屋市西区：せ行」",
            "weight": "bold",
            "size": "sm",
            "wrap": true,
            "decoration": "none"
          },
          {
            "type": "box",
            "layout": "baseline",
            "contents": []
          },
          {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "box",
                "layout": "baseline",
                "spacing": "sm",
                "contents": [
                  {
                    "type": "text",
                    "text": "表示したい地域を選択してください",
                    "wrap": true,
                    "color": "#444444",
                    "size": "xs",
                    "flex": 5
                  }
                ]
              }
            ]
          }
        ],
        "spacing": "sm",
        "paddingAll": "13px",
        "backgroundColor": "#FFC60B"
      },
      "footer": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "button",
            "action": {
              "type": "postback",
              "label": "浅間一丁目",
              "data": "浅間一丁目",
              "displayText": "浅間一丁目"
            },
            "height": "sm",
            "color": "#757575"
          },
          {
            "type": "button",
            "action": {
              "type": "postback",
              "label": "浅間二丁目",
              "data": "浅間二丁目",
              "displayText": "浅間二丁目"
            },
            "height": "sm",
            "color": "#757575"
          }
        ]
      }
    }
  ]
}
  end
end

