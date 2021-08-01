require_relative 'game'
require_relative 'channel'
require_relative 'orga_choice'

require_relative 'common'

class Server < ActiveRecord::Base
  has_many :channels
  has_many :games
  has_many :orga_choices
  has_many :poll_models

  extend Models::Common
end