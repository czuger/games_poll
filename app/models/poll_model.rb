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
end