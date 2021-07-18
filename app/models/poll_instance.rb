require_relative 'common'

class PollInstance < ActiveRecord::Base
  has_many :votes
  has_many :voters, through: :votes

  has_and_belongs_to_many :games

  extend Common
end