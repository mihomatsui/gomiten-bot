require 'clockwork'
require 'minute_job'

module Clockwork
  handler do |job|
    job.call
  end

  every(30.minutes, MinuteJob.new)
end

