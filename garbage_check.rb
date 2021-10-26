class GarbageCheck
  require 'date'
  require_relative 'date_check'

  def self.target_day
    @target_day ||= Date.tomorrow
  end

  # 燃えるゴミ
  def self.burnable_garbage?
  end

  # 缶・ビン・ペットボトル
  def self.recyclable_garbage?

  end

  # プラスチック
  def self.plastic_garbage?
  end

  # 不燃ゴミ
  def self.not_burnable_garbage?
  end

  def self.check
    return :burnable_garbage if burnable_garbage?
    return :recyclable_garbage if recyclable_garbage?
    return :plastic_garbage if plastic_garbage?
    return :not_burnable_garbage if not_burnable_garbage?
    :none
  end

  def self.notice_message
    message = case check
    when :burnable_garbage then '燃えるゴミの日です'
    when :recyclable_garbage then '缶・ビン・ペットボトルの日です'
    when :plastic_garbage then 'プラスチックゴミの日です'
    when :not_burnable_garbage then '不燃ゴミの日です'
    else '特に出せるゴミはありません'
    end
    "明日(#{target_day.strftime("%m月%d日 %a")})は、#{message}"
  end
end