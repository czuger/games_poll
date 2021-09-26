require_relative '../../models/server'
require_relative '../../models/poll'

module Commands
  module Polls
    class Add

      # Create a new poll
      def self.pa(discord_server_id, message_content)
        content = message_content.split
        content.shift
        name = content.shift
        title = content.join(' ')

        ActiveRecord::Base.transaction do
          server = Server.get_or_create(discord_server_id)

          if Poll.where(server_id: server.id, name: name).exists?
            return "Poll #{name} already exists"
          elsif title.nil? || title == ''
            return 'A title is mandatory (use gp!pa <poll_name> <poll_title>'
          else

            pm = Poll.where(server_id: server.id, name: name).first_or_initialize
            pm.title = title
            pm.save!

            pm.add_games(server.games.where(favored: true))
          end
        end
        # end
        "Poll #{name} added"
      end
    end
  end
end