# frozen_string_literal: true

require 'logger'

class DualLogger

  attr_reader :config

  def config
    @application.config
  end

  def initialize application
    @application = application
    v_para = {
      level: MessageLevel::severity(config[:verbose])
    }
    @verb = Logger::new STDERR, **v_para
    if config[:log][:enable]
      f_para = {
        level: MessageLevel::severity(config[:log][:level]),
      }
      f_para[:shift_age] = config[:log][:shift][:age] if config[:log][:shift][:age]
      f_para[:shift_level] = config[:log][:shift][:level] if config[:log][:shift][:level]
      @file = Logger::new config[:log][:file], **f_para
    else
      @file = nil
    end
  end

  def log task, severity, message
    task = task.name if task.respond_to?(:name)
    @verb.log(MessageLevel::severity(severity), message, task)
    @file.log(MessageLevel::severity(severity), message, task) if @file
  end

end
