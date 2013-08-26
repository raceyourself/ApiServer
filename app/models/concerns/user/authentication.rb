class User
  module Authentication
    extend ActiveSupport::Concern

    module ClassMethods
  
      def find_for_provider_oauth(auth, signed_in_resource=nil)
        user = where(provider: auth.provider, uid: auth.uid).first
        unless user
          user = create(
            name:auth.extra.raw_info.name,
            provider:auth.provider,
            uid:auth.uid,
            email:auth.info.email,
            password:Devise.friendly_token[0,20]
          )
        end
        user
      end #find_for_facebook_oauth

      def new_with_session(params, session)
        super.tap do |user|
          
          if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
            user.email = data["email"] if user.email.blank?
          end

          if data = session['devise.linkedin_data'] && session['devise.linkedin_data']['user_info']
            user.email = data['email']
          end

        end
      end

    end #ClassMethods
  end #Oauth
end #User