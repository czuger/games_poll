require_relative 'common'

class PollInstance < ActiveRecord::Base
  has_many :votes
  has_many :voters, through: :votes

  has_and_belongs_to_many :games

  extend Models::Common

  BASE_EMOJII = 127462

  def self.num_to_emoji(i)
    emojii_code = BASE_EMOJII + i
    [emojii_code].pack('U*')
  end

  def show(event)
    result = event.channel.send_embed do |embed|
      embed.title = 'A quoi voulez vous jouer samedi.'

      1.upto(5).each do
        games.order(:name).each_with_index do |g, i|
          msg = "#{PollInstance.num_to_emoji(i)} : #{g.name}"
          p msg
          # e.add_field(name: "\u200b", value: msg, inline: true)
          embed.add_field(name: "\u200b", value: msg, inline: false)
        end
      end
    end

    games.order(:name).each_with_index do |g, i|
      sleep(0.1)
      result.create_reaction(PollInstance.num_to_emoji(i))
    end
  end

end