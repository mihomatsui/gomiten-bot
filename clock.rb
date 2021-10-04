require 'clockwork'
require './hour_job'

module Clockwork
  handler do |job|
    job.call
  end

  #7時より前に実行してスリープを解除する
  every(1.hour, HourJob.new, :thread => true, at: '6:30') { sleep 30 }
  every(1.hour, HourJob.new, :thread => true, at: '7:00')
end

