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
        @user = User.find_for_provider_oauth(request.env["omniauth.auth"], current_user)

        if @user.persisted?
          if current_user
            redirect_to root_url
          else
            sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
            set_flash_message(:notice, :success, :kind => request.env["omniauth.auth"]["provider"].humanize) if is_navigational_format?
          end
        else
          data = request.env["omniauth.auth"].except("extra")
          data["x-access-level"] = request.env["omniauth.auth"].extra.access_token.response.header["x-access-level"] if request.env["omniauth.auth"].extra
          session["devise.provider_data"] = data
          redirect_to new_user_registration_url
        end
      end #standard_provider

  end #OmniauthCallbacksController
end #Users 
