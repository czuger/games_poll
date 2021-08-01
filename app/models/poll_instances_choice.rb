require_relative 'common'

class PollInstancesChoice < ActiveRecord::Base
  belongs_to :poll_instance
  belongs_to :choice, polymorphic: true
end