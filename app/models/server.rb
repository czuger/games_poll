# require_relative 'game'

require_relative 'common'

class Server < ActiveRecord::Base
  has_many :channels
  has_many :games

  extend Common
end