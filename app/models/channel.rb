require_relative 'common'

class Channel < ActiveRecord::Base
  has_many  :poll_instances

  extend Models::Common
end