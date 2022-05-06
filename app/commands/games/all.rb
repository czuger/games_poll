require_relative '../../models/server'
require_relative '../../models/game'
require_relative '../common'

module Commands
  module Games
    class All

      def self.find_and_exec(message_content)
        content = message_content.split

        content.shift
        game_id = content.shift
        g = Game.find(game_id)

        if g
          yield g, content
          event.channel.send_temporary_message('Done', 30)
        else
          event.channel.send_temporary_message('Game not found', 30)
        end
      end

      # Game add
      def self.ga(discord_server_id, message_content)
        s = Server.get_or_create discord_server_id
        content = message_content.split

        content.shift
        name = content.join(' ')

        g = Game.where(server_id: s.id, name: name).first_or_initialize
        g.name = name
        g.save!
        'Game added'
      end

      # Game list
      def self.gl(event, discord_server_id)
        s = Server.get_or_create discord_server_id

        game_list_message = s.games.order(:name).map{ |e| "#{e.id} - #{e.name} #{('+' if e.favored)}\n" }.join
        # p game_list_message
        event.channel.send_temporary_message(game_list_message, 30)
      end

    end
  end
end
