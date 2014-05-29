class RegistrationsController < Devise::RegistrationsController

  before_filter :configure_permitted_parameters
 

  def create
    Rails.logger.info(params[:invite_code])
    # By code
    invite = Invite.where(:code => params[:invite_code]).first
    # By invited e-mail
    invite = Invite.where(:identity_type => 'EmailIdentity').where(:identity_uid => params[:email]).first unless invite
    # TODO: By invited third-party identity
    raise 'Closed beta' unless invite || params[:invite_code] == 'adminadmin'

    build_resource(sign_up_params)

    if resource.save

      if omniauth = session.delete("devise.provider_data")
        auth = resource.authentications.build.tap do |a|
          a.provider  = omniauth.provider
          a.uid       = omniauth.uid
          a.update_from_omniauth(omniauth)
        end
        auth.save
      end

      # Destroy accepted invite
      invite.destroy if invite

      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end




  protected
    def configure_permitted_parameters
      
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:name, :username, :email, :image, :image_cache)
      end

      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(:name, :username, :email, :password, :password_confirmation, :current_password, :image, :image_cache)
      end
    end
end
