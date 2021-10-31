require 'colorize'


class GpLogs

  @@logger = nil

  def self.debug(msg, calling_class=nil, calling_method=nil)
    get_logger.debug(make_msg(msg, calling_class, calling_method))
  end

  def self.info(msg, calling_class=nil, calling_method=nil)
    get_logger.info(make_msg(msg, calling_class, calling_method).blue)
  end

  def self.warn(msg, calling_class=nil, calling_method=nil)
    get_logger.warn(make_msg(msg, calling_class, calling_method).yellow)
  end

  def self.error(msg, calling_class=nil, calling_method=nil)
    get_logger.info(make_msg(msg, calling_class, calling_method).red)
  end

  def self.fatal(msg, calling_class=nil, calling_method=nil)
    get_logger.fatal(make_msg(msg, calling_class, calling_method).red.on_black)
  end

  private

  def self.make_msg(msg, calling_class, calling_method)
    (calling_class || calling_method) ? "#{calling_class}@#{calling_method} : #{msg}" : msg
  end

  def self.get_logger
    @@logger ||= Logger.new('log/general.log')
    @@logger
  end

end