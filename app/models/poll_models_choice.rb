require_relative 'common'

class PollModelsChoice < ActiveRecord::Base
  belongs_to :poll_instance
  belongs_to :choice, polymorphic: true

  def is_others_games_button?
    if choice_type == 'OrgaChoice'
      return choice.other_game_action
    end
    false
  end

end