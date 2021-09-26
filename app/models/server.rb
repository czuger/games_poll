require_relative 'game'
require_relative 'channel'
require_relative 'server_choice'

require_relative 'common'

class Server < ActiveRecord::Base
  has_many :channels
  has_many :games
  has_many :server_choices
  has_many :poll_models

  extend Models::Common

  def get_or_create_channel(discord_id)
    Channel.get_or_create discord_id, self.id
  end
end