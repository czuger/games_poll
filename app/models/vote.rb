require_relative 'voter'

class Vote < ActiveRecord::Base
  belongs_to :voter
  belongs_to :poll
  belongs_to :choice, polymorphic: true

  BASE_EMOJII = 127462

  def self.num_to_emoji(i)
    emojii_code = BASE_EMOJII + i
    [emojii_code].pack('U*')
  end

  def self.emoji_to_num(emoji_name)
    emoji_number = emoji_name.ord - BASE_EMOJII
    puts "Emoji reaction : #{emoji_number}"
    emoji_number
  end

end
