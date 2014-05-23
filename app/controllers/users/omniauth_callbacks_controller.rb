module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def facebook
      standard_provider
      if @user.persisted?
        FacebookFriendsWorker.perform_async(@user.id)
      end
    end

    def twitter
      standard_provider
      if @user.persisted?
        TwitterFriendsWorker.perform_async(@user.id)
      end
    end

    def gplus 
      standard_provider
      if @user.persisted?
        GplusFriendsWorker.perform_async(@user.id)
      end
    end


    protected

      def standard_provider
        begin
          @user = User.find_for_provider_oauth(request.env["omniauth.auth"], current_user)
        rescue => e
          reason = e.message || 'link to provider failed'
          set_flash_message(:error, :failure, :kind => request.env["omniauth.auth"]["provider"].humanize, :reason => reason) if is_navigational_format?
          redirect_to root_url
        end

        if @user.persisted?
          if current_user
            redirect_to root_url
          else
            # Send confirmation e-mail if invited and has iOS device
            invite = Invite.where(code: session['invite_code']) if session['invite_code']
            unless invite
              identity = ::Identity.where(provider: request.env["omniauth.auth"].provider, uid: request.env["omniauth.auth"].uid).first if request.env["omniauth.auth"]
              invite = identity.invites.first if identity
            end

            if session['device']
              profile = User.find(@user.id).profile || {}
              devices = profile['devices_reported'] || []
              devices << session['device']
              profile['devices_reported'] = devices
              @user.update!(profile: profile)
            end

            iPhone = @user.profile['devices_reported'].find do |device|
              device.downcase.include? 'iphone'
            end if @user.profile && @user.profile['devices_reported']

            if invite && iPhone.present?
              user.send_confirmation_instructions
            end

            invite.destroy if invite

            session['invited'] == invite.present?
            session['iPhone'] == iPhone.present?

            sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
            set_flash_message(:notice, :success, :kind => request.env["omniauth.auth"]["provider"].humanize) if is_navigational_format?
          end
        elsif false # Disabled atm
          data = request.env["omniauth.auth"].except("extra")
          data["x-access-level"] = request.env["omniauth.auth"].extra.access_token.response.header["x-access-level"] if request.env["omniauth.auth"].extra
          session["devise.provider_data"] = data
          redirect_to new_user_registration_url
        end
      end #standard_provider

  end #OmniauthCallbacksController
end #Users 
