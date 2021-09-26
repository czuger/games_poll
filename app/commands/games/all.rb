require_relative '../../models/server'
require_relative '../../models/game'
require_relative '../common'

module Commands
  module Games
    class All

      def self.find_and_exec(event)
        content = event.message.content.split

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
      def self.ga(event)
        s = Server.get_or_create event.server.id
        content = event.message.content.split

        content.shift
        name = content.join(' ')

        g = Game.where(server_id: s.id, name: name).first_or_initialize
        g.name = name
        g.save!
      end

      # Game update
      def self.gu(event)
        self.find_and_exec(event) do |g, content|
          name = content.join(' ')
          g.name = name
          g.save!
        end
      end

      # Game del
      def self.gd(event)
        self.find_and_exec(event) do |g, _|
          g.destroy!
        end
      end

      # Set game favored status
      def self.gf(event)
        self.find_and_exec(event) do |g, _|
          g.favored = !g.favored
          g.save!
        end
      end

      # Game list
      def self.gl(event)
        s = Server.get_or_create event.server.id

        game_list_message = s.games.order(:name).map{ |e| "#{e.id} - #{e.name} #{('+' if e.favored)}\n" }.join
        p game_list_message
        event.channel.send_temporary_message(game_list_message, 30)
      end

    end
  end
end
