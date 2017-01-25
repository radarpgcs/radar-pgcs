module LoginConcern
  extend ActiveSupport::Concern

  def logged_in?
    !session[:user_so].nil?
  end
  
  def authenticate_login(uid, pass)
    user = User.where(registry: uid).first
    if user.nil?
      Rails.logger.info "Login: Unknown user identification #{uid}"
      return
    end

    auth_ok = _password_match? user, pass
    Rails.logger.info "Login: Invalid password to user with identification #{uid}" unless auth_ok

    user
  end

  def log_in(user)
    session[:user_so] = {
      :registry => user.registry
    }

    Auditing.new do |e|
      e.user = user
      e.ip = request.remote_ip
      e.event = 'LOGIN'
      e.event_date = Time.now
    end.save
  end

  def caller_url
    regex = /\Ahttps?:\/\/(#{request.host}):?(#{request.port})?/
    if (request.referer =~ regex) == 0
      caller_path = request.referer.sub regex, ''
      ((caller_path != login_path) && (caller_path != sign_in_path)) ? caller_path : home_path
    else
      home_path
    end
  end

  private
  def _password_match?(user, raw_password)
    pass_hash = Services::Security.generate_hash(raw_password, user.salt_number)
    user.password == pass_hash
  end
end