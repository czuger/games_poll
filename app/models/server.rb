require_relative 'game'
require_relative 'server_choice'

require_relative 'common'

class Server < ActiveRecord::Base
  has_many :channels
  has_many :games
  has_many :server_choices
  has_many :polls

  extend Models::Common

  def self.get_or_create(server_id)
    object = self.where(discord_id: server_id).first_or_initialize
    object.save!
    object
  end

  def get_or_create_channel(discord_id)
    Channel.get_or_create discord_id, self.id
  end

  def get_poll(message_content)
      content = message_content.split
      content.shift
      poll_name = content.shift

      Poll.where(server_id: self.id, name: poll_name).first
  end
end