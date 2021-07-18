require_relative 'poll_schedule'

class PollModel < ActiveRecord::Base
  has_many :poll_instances
  has_many :poll_schedules
end