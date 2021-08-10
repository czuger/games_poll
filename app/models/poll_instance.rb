require_relative 'poll_model'
require_relative 'common'
require_relative 'vote'
require_relative '../libs/embed'

class PollInstance < ActiveRecord::Base
  belongs_to :poll_model

  has_many :votes
  has_many :voters, through: :votes

  extend Models::Common

  def show(event)
    result = event.channel.send_embed do |embed|
      Embed.generate_embed_votes(embed, self)
    end

    poll_model.poll_models_choices.order(:emoji).each do |pic|
        sleep(0.1)
        result.create_reaction(Vote.num_to_emoji(pic.emoji))
    end

    self.discord_id = result.id
    self.save!
  end

end