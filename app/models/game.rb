# Contains the games choices for a server.

class Game < ActiveRecord::Base

  def first_row
    false
  end

  def emoji
    nil
  end

  def button_style
    nil
  end

  def run_command
    nil
  end

end