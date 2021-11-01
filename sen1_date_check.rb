# 西区浅間一丁目のゴミ収集日のデータ
class GarbageDateSen1
  require 'date'
  require_relative 'date_patch'
  
  def self.target_day
    @target_day ||= Date.tomorrow
  end

  def self.burnable_garbage? #可燃ゴミ
    target_day.monday? || target_day.thursday?
  end

  def self.not_burnable_garbage? #不燃ゴミ
    now = target_day
    now.wednesday? && now.mweek == 4
  end

  def self.plastic_garbage? #プラスチックゴミ
    target_day.friday?
  end

  def self.bottle_can_garbage? #缶・ビン・ペットボトル
    target_day.wednesday?
  end

  def self.check
     return :burnable_garbage if burnable_garbage?
     return :not_burnable_garbage if not_burnable_garbage?
     return :plastic_garbage if plastic_garbage?
     return :bottle_can_garbage if bottle_can_garbage?
  end
    
  def self.notice_message
    garbage_message = case check
    when :burnable_garbage then '可燃ゴミの日です'
    when :not_burnable_garbage then '不燃ゴミの日です'
    when :plastic_garbage then 'プラスチックゴミの日です'
    when :bottle_can_garbage then '缶・ビン・ペットボトルの日です'
    else '特に出せるゴミはありません'
    end
    # Botでメッセージを表示する
    message = ''
    message << %{明日(#{target_day.strftime("%m月%d日%a")})は、}
    message << %{#{garbage_message}}
    return message
  end
end