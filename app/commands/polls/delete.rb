require_relative '../../models/server'
require_relative '../../models/poll'
require_relative '../../models/vote_history'

module Commands
  module Polls
    class Delete

      # Restart a poll
      def self.pdel(poll, discord_channel)

        ActiveRecord::Base.transaction do
          poll.votes.where(choice_type: 'Game').each do |v|
            VoteHistory.create!(
              voter_id: v.voter_id, game_id: v.choice_id
            )
          end

          poll.votes.destroy_all
          poll.destroy

        end

        "Poll #{poll.name} deleted successfully."
      end
    end
  end
end