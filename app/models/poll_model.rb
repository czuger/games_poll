# class PollModel < ActiveRecord::Base
#   belongs_to :server
#
#   has_many :polls
#
#   # Check for a poll instance or create it
#   def get_or_create_instance(event)
#     s = Server.get_or_create event.server.id
#     c = s.get_or_create_channel event.channel.id
#
#     # We need the last instance of this poll_model on this channel
#     pi = Poll.where(poll_model_id: self.id, channel_id: c.id).order(:discord_message_id).last
#
#     unless pi
#       pi = Poll.create!(poll_model_id: self.id, channel_id: c.id, discord_message_id: event.message.id)
#       pi.add_games(s.games.where(favored: true))
#     end
#
#     # pi.save!
#     pi
#   end
#
# end