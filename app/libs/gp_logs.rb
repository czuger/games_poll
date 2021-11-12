require 'colorize'
require 'log_formatter'
require 'log_formatter/ruby_json_formatter'

class GpLogs

  @@logger = nil

  def self.debug(msg, calling_class=nil, calling_method=nil)
    get_logger.debug(make_msg(msg, calling_class, calling_method))
  end

  def self.info(msg, calling_class=nil, calling_method=nil)
    get_logger.info(make_msg(msg, calling_class, calling_method))
  end

  def self.warn(msg, calling_class=nil, calling_method=nil)
    get_logger.warn(make_msg(msg, calling_class, calling_method))
  end

  def self.error(msg, calling_class=nil, calling_method=nil)
    get_logger.info(make_msg(msg, calling_class, calling_method))
  end

  def self.fatal(msg, calling_class=nil, calling_method=nil)
    get_logger.fatal(make_msg(msg, calling_class, calling_method))
  end

  private

  def self.make_msg(msg, calling_class, calling_method)
    (calling_class || calling_method) ? "#{calling_class}@#{calling_method} : #{msg}" : msg
  end

  def self.get_logger
    unless @@logger
      @@logger = Logger.new('log/general.log')
      @@logger.formatter = Ruby::JSONFormatter::Base.new 'games_poll', {'source': 'general'}

    end

    @@logger
  end

end