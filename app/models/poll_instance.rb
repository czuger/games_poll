require_relative 'common'

class PollInstance < ActiveRecord::Base
  has_many :votes
  has_many :voters, through: :votes

  has_many :poll_instances_games
  has_many :games, -> { order 'poll_instances_games.emoji' }, through: :poll_instances_games

  extend Models::Common

  BASE_EMOJII = 127462

  def self.num_to_emoji(i)
    emojii_code = BASE_EMOJII + i
    [emojii_code].pack('U*')
  end

  def show(event)
    result = event.channel.send_embed do |embed|
      # embed.title = 'A quoi voulez vous jouer samedi.'
      title = 'A quoi voullez vous jouer samedi ?'

      games_list = []

      games.order(:name).each_with_index do |g, i|
        msg = "#{PollInstance.num_to_emoji(i)} : #{g.name}"
        games_list << msg
      end

      embed.add_field(name: title, value: games_list.join("\n"), inline: false)
    end

    games.order(:name).each_with_index do |g, i|
      sleep(0.1)
      result.create_reaction(PollInstance.num_to_emoji(i))
    end

    self.discord_id = result.id
  end

end