require_relative 'poll_choice'
require_relative 'common'
require_relative 'vote'
require_relative 'channel'
require_relative '../libs/embed'

# A poll object
# A poll name is unique on a server
class Poll < ActiveRecord::Base
  belongs_to :server
  belongs_to :channel, optional: true

  has_many :votes
  has_many :voters, through: :votes

  has_many :add_other_games

  has_many :poll_choices
  # has_many :choices, -> { order 'poll_instances_games.emoji' }, through: :poll_instances_choices

  extend Models::Common

  def show(channel)
    new_message = channel.send_embed do |embed|
      Embed.generate_embed_votes(embed, self)
    end

    self.poll_choices.order(:emoji).each do |pic|
        sleep(0.1)
        p new_message.create_reaction(Vote.num_to_emoji(pic.emoji))
    end

    # As we created a new message, we need to relink the poll_instance to that new message id.
    self.discord_message_id = new_message.id
    self.save!
  end

  def add_games(games)
    server = self.server

    emoji = 0
    server.server_choices.where(before: true).order(:name).each do |orga|
      emoji = set_models_choice(self, emoji, orga)
    end

    games_ids = poll_choices.where(choice_type: 'Game').pluck(:choice_id)
    games_ids += games.map{ |e| e.id }

    server.games.where(id: games_ids).order(:name).each do |g|
      emoji = set_models_choice(self, emoji, g)
    end

    server.server_choices.where(before: false).order(:name).each do |orga|
      emoji = set_models_choice(self, emoji, orga)
    end
  end

  private

  def set_models_choice(pi, emoji, choice)
    pig = PollChoice.where(poll_id: pi.id, emoji: emoji).first_or_initialize
    pig.choice = choice
    pig.save!
    emoji + 1
  end

end