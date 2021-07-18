require_relative 'common'

class PollInstance < ActiveRecord::Base
  has_many :poll_instances

end