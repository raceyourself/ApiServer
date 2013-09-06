module Concerns
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
          
          if data = session["devise.provider_data"]
            user.email = data['info']["email"] if data['info']["email"] && user.email.blank?
            user.username = data['info']['nickname'] if user.username.blank?
            user.provider = data['provider']
            user.uid = data['uid']
            user.token = data['credentials']['token']
          end

        end
      end

    end # ClassMethods
  end # Authentication
end # Concerns
