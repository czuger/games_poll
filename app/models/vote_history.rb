require_relative 'voter'
require_relative 'game'

class VoteHistory < ActiveRecord::Base
  belongs_to :voter
  belongs_to :game
end
