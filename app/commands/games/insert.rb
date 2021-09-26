require_relative '../../models/server'

module Commands
  module Games
    class Insert

      def self.gi_insert(server, title, favored)
        title.strip!
        game = server.games.where(name: title).first_or_initialize
        game.favored = favored
        game.save!
      end

      def self.gi(discord_server_id)
        s = Server.get_or_create discord_server_id

        ActiveRecord::Base.transaction do
          File.open('data/favored.txt').readlines.each do |title|
            self.gi_insert(s, title, true)
          end
          File.open('data/regular.txt').readlines.each do |title|
            self.gi_insert(s, title, false)
          end

          [['Present avec les clefs', true, false], ['Autres', false, true], ['Absent', false, false]].each do |e|
            g = s.server_choices.where(name: e[0]).first_or_initialize
            g.before = e[1]
            g.other_game_action = e[2]
            g.save!
          end
        end
        'Done'
      end

    end
  end
end
