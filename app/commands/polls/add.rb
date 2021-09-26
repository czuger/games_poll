require_relative '../../models/server'
require_relative '../../models/poll'

module Commands
  module Polls
    module Add

      # Create a new poll
      def self.pa(discord_server_id, discord_channel_id, message_content)
        content = message_content.split
        content.shift
        name = content.shift
        title = content.join(' ')

        server = Server.get_or_create(discord_server_id)
        channel = Channel.get_or_create(discord_channel_id, server.id)

        ActiveRecord::Base.transaction do
          pm = Poll.where(channel_id: channel.id, name: name).first_or_initialize
          pm.title = title
          pm.save!

          pm.add_games(server.games.where(favored: true))
          # pi.show event
          # The id of the message is changed during show. So, we need the id of the message
          # we created, not the id of the command that required poll creation.
          # pm.save!
        end
        # end
        "Poll #{name} added"
      end

    end
  end
end