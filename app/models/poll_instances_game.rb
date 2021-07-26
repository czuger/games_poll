require_relative 'common'

class PollInstancesGame < ActiveRecord::Base
  belongs_to :poll_instance
  belongs_to :game
end