class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_admin_user

  def current_admin_user
    return current_user if current_user && current_user.admin?
    raise Exception.new("You're not an admin")
  end

  def after_sign_in_path_for(user)
    return confirmation_url(user) unless user.confirmed?
    if user.admin?
      super
    else
      'http://beta.raceyourself.com/login?token=' + user.id.to_s
    end
  end
end
