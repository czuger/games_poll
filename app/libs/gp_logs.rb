require 'colorize'

class GpLogs

  @@logger = nil

  def self.debug(msg)
    get_logger.debug(msg)
  end

  def self.info(msg)
    get_logger.info(msg.blue)
  end

  def self.warn(msg)
    get_logger.warn(msg.yellow)
  end

  def self.error(msg)
    get_logger.info(msg.red)
  end

  def self.fatal(msg)
    get_logger.fatal(msg.red.on_black)
  end


  private

  def self.get_logger
    @@logger ||= Logger.new('logs/general.log')
    @@logger
  end

end