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
    return super if user.admin?
    
    beta = Doorkeeper::Application.where(:name => 'BetaWeb').first
    return super unless beta
    access_token = Doorkeeper::AccessToken.create!(:application_id => beta.id, :resource_owner_id => user.id, :expires_in => 1.seconds, :use_refresh_token => true)
    return 'http://beta.raceyourself.com/login?refresh_token=' + access_token.refresh_token
  end
end
