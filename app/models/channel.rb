require_relative 'server'
require_relative 'common'

class Channel < ActiveRecord::Base
  belongs_to :server

  has_many  :polls

  extend Models::Common

  def self.get_or_create(discord_id, server_id)
    object = self.where(discord_id: discord_id).first_or_initialize
    object.server_id = server_id
    object.save!
    object
  end

end