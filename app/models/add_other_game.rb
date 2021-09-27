require_relative 'common'

# The temporary message that will be shown to the user asking him to choose another game.
class AddOtherGame < ActiveRecord::Base
  belongs_to :poll

  serialize :choices
end