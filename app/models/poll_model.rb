require_relative 'poll_schedule'

class PollModel < ActiveRecord::Base
  belongs_to :server

  has_many :poll_instances
  has_many :poll_schedules

  has_many :poll_models_choices
  # has_many :choices, -> { order 'poll_instances_games.emoji' }, through: :poll_instances_choices

  # Check for a poll instance or create it
  def get_or_create_instance(event)
    s = Server.get_or_create event.server.id
    c = s.get_or_create_channel event.channel.id

    pi = PollInstance.where(
      poll_model_id: self.id, channel_id: c.id, discord_id: event.message.id).first_or_initialize
    pi.save!
    pi
  end

  def add_games(games)
    emoji = 0
    server.orga_choices.where(before: true).order(:name).each do |orga|
      emoji = set_models_choice(self, emoji, orga)
    end

    games_ids = poll_models_choices.where(choice_type: 'Game').pluck(:choice_id)
    games_ids += games.map{ |e| e.id }

    server.games.where(id: games_ids).order(:name).each do |g|
      emoji = set_models_choice(self, emoji, g)
    end

    server.orga_choices.where(before: false).order(:name).each do |orga|
      emoji = set_models_choice(self, emoji, orga)
    end
  end

  private

  def set_models_choice(pm, emoji, choice)
    pig = PollModelsChoice.where(poll_model_id: pm.id, emoji: emoji).first_or_initialize
    pig.choice = choice
    pig.save!
    emoji + 1
  end
end