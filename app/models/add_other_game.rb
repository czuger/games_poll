require_relative 'common'

class AddOtherGame < ActiveRecord::Base
  belongs_to :poll_instance

  serialize :choices
end