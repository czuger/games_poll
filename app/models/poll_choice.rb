require_relative 'common'

class PollChoice < ActiveRecord::Base
  belongs_to :poll
  belongs_to :choice, polymorphic: true

  def is_others_games_button?
    if choice_type == 'ServerChoice'
      return choice.other_game_action
    end
    false
  end

end