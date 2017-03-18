module AppLogger
  @@classes = {}

  def debug(msg)
    log level: :debug, top_step: caller.first, message: msg
  end

  def info(msg)
    log level: :info, top_step: caller.first, message: msg
  end

  def warn(msg, throwable = nil)
    log level: :warn, top_step: caller.first, message: msg, throwable: throwable
  end

  def error(msg, throwable = nil)
    log level: :error, top_step: caller.first, message: msg, throwable: throwable
  end

  def fatal(msg, throwable = nil)
    log level: :fatal, top_step: caller.first, message: msg, throwable: throwable
  end

  def unknown(msg)
    log level: :unknown, top_step: caller.first, message: msg
  end

  private
  def log(options)
    params = /([\w\d]+.rb):(\d+):in\s`([\w\d\s]+)'/.match(options[:top_step]).captures
    message = "[#{options[:level].to_s.upcase}] (#{class_name params[0]}:#{params[2]}:#{params[1]}) #{options[:message]}"
    Rails.logger.send(options[:level], message)
    puts '    ' + options[:throwable].backtrace.join("\n    ") if options[:throwable]
  end

  def class_name(file_name)
    if @@classes[file_name]
      @@classes[file_name]
    else
      clazz = file_name.sub('.rb', '').split('_').collect { |token| token.capitalize }.join
      @@classes[file_name] = clazz
    end
  end
end