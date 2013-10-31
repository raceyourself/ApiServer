module Concerns
  module Authentication
    extend ActiveSupport::Concern

    included do
      has_many :authentications, dependent: :destroy

    end

    module ClassMethods

      def find_for_provider_oauth(omniauth, signed_in_resource=nil)
        
        auth = ::Authentication.where(provider: omniauth.provider, uid: omniauth.uid).first

        if auth
          raise "This account has already been used by another system user" if signed_in_resource && signed_in_resource != auth.user
          auth.update_from_omniauth(omniauth)
          auth.save
          return auth.user
        else
          user = signed_in_resource

          if user.nil?
            # create a new user
            user = User.new(
              name: omniauth.extra.raw_info.name,
              password: Devise.friendly_token[0,20],
              email: omniauth.info.email
            )
            # Skip confirmation for third-party identity providers
            user.skip_confirmation!
            user.save
          end
          auth = user.authentications.build.tap do |a|
            a.provider  = omniauth.provider
            a.uid       = omniauth.uid
          end
          auth.update_from_omniauth(omniauth)
          auth.save
          logger.debug("User is: #{user}")
          return user
        end
      end #find_for_facebook_oauth

      def new_with_session(params, session)

        super.tap do |user|
          
          if data = session["devise.provider_data"]
            user.email =    data.info.email     if data.info && data.info.email && user.email.blank?
            user.username = data.info.nickname  if user.username.blank?
            user.confirmed_at = Time.now
          end

        end

      end

    end # ClassMethods
  end # Authentication
end # Concerns
