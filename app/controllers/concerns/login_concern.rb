module LoginConcern
  extend ActiveSupport::Concern

  def current_user
    return @current_user if @current_user
    @current_user = User.find_by registry: session[:user_so]['registry']
  end

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

    auth_ok ? user : nil
  end

  def log_in(user)
    if user.status == 'BLOCKED'
      flash[:danger] = t 'sign_in.blocked_user', user: user.registry, note: user.status_note
      render('/login', layout: false)
    elsif user.status == 'INACTIVE'
      flash[:warning] = t 'sign_in.inactive_user'
      redirect_to activate_user_path(registry: user.registry)
    else
      _login user
    end
  end

  def log_out
    session.delete(:user_so)
    Services::Security.audit_logout(@current_user, request.remote_ip)
    @current_user = nil

    message = (logged_in?) ? "User #{current_user.registry} has just signed out." : 'Session destroyed by expiration.'
    Rails.logger.info message
    redirect_to home_path
  end

  def activate_account
    options = {
      registry: params[:registry],
      new_password: params[:new_password],
      confirm_password: params[:confirm_password]
    }

    begin
      Services::Security.activate_account options
      flash[:info] = t 'activate_user.activation_success'
      _login User.find_by(registry: params[:registry]), home_path
    rescue RuntimeError => e
      flash[:danger] = e.message
      @employee = Employee.find_by registry: params[:registry]
      render '/activate_user', layout: 'public'
    end
  end

  private
  def _login(user, url = _caller_url)
    _save_session user
    Services::Security.audit_login(user, request.remote_ip)

    user.update_attribute('last_login', Time.now)

    Rails.logger.info "User '#{session[:user_so][:nickname]}' has just signed in."
    redirect_to url
  end

  def _password_match?(user, raw_password)
    pass_hash = Services::Security.generate_hash(raw_password, user.salt_number)
    user.password == pass_hash
  end

  def _save_session(user)
    e = Employee.find_by registry: user.registry

    session[:user_so] = {
      registry: user.registry,
      nickname: "#{e.registry}: #{e.name.split(/\s+/).first.capitalize}",
      department: e.department,
      hiring_date: e.hiring_date.to_s.split('-').join(' '),
      regional: e.regional
    }
  end

  def _caller_url
    regex = /\Ahttps?:\/\/(#{request.host}):?(#{request.port})?/
    if (request.referer =~ regex) == 0
      caller_path = request.referer.sub regex, ''
      ((caller_path != login_path) && (caller_path != sign_in_path)) ? caller_path : home_path
    else
      home_path
    end
  end
end