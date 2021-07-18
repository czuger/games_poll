# require_relative 'game'

require_relative 'common'

class Server < ActiveRecord::Base
  has_many :channels
  has_many :games
  has_many :poll_models

  extend Models::Common
end