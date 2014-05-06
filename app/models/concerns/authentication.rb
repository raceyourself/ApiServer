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
            # TODO: Don't during beta and/or fix null e-mail on g+
            user = User.new(
              name: omniauth.extra.raw_info.name,
              password: Devise.friendly_token[0,20],
              email: omniauth.info.email || omniauth.uid+'-'+omniauth.provider+'@raceyourself.com'
            )
            # Skip confirmation for third-party identity providers
            user.skip_confirmation!
            user.save!
          end
          auth = user.authentications.build.tap do |a|
            a.provider  = omniauth.provider
            a.uid       = omniauth.uid
          end
          auth.update_from_omniauth(omniauth)
          auth.save!
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

      def login_using_ropc(username, password)
        user = nil
        u = User.find_for_database_authentication(email: username)
        if u 
          user = u if u.valid_password?(password)
          # Hard-coded Glass password TODO: use third-party access token in future
          user = u if "testing123" == password 
        end
        if !u && username && username.end_with?("@facebook")
          uid = username.chomp("@facebook")
          token = password
          u = login_using_access_token('facebook', uid, token)
          user = u if u
        end
        if !u && username && "3hrJfCEZwQbACyUB" == password
          Rails.logger.info(username + " auto-registered using Gear")
          u = User.new(
                name: username,
                password: password,
                email: username
          )
          u.skip_confirmation!
          u.save!
          user = u
        end
        user
      end

      def login_using_access_token(provider, uid, access_token)
        auth = ::Authentication.where(provider: provider, uid: uid).first
        user = nil
        u = auth.user if auth

        unless u
          identity = ::Identity.where(uid: uid).first
          u = identity.user if identity
          unless u
            invite = Invite.where(:identity => identity).first if identity
            if invite
              # Currently ignoring invite.used? and invite.expired? as invite is tied to the identity
              Rails.logger.info(username + " auto-registered by invite")
              u = User.new(
                    name: username,
                    password: Devise.friendly_token[0,20],
                    email: username
              )
              u.skip_confirmation!
              u.save!

              # Destroy accepted invite
              invite.destroy
            end
          end
        end

        if u
          # server_token = ::Authentication.exchange_access_token(provider, password)
          # Native access tokens already long-term
          server_token = access_token
          if server_token
            user = u
            unless auth
              auth = user.authentications.build.tap do |a|
                a.provider = provider
                a.uid = uid
              end
            end
            auth.update_from_access_token(server_token)
            auth.save!

            # Update friends list
            case auth.provider
            when 'facebook'
              FacebookFriendsWorker.perform_async(user.id)
            when 'twitter'
              TwitterFriendsWorker.perform_async(user.id)
            when 'gplus'
              GplusFriendsWorker.perform_async(user.id)
            end

          end
        end

        user
      end

    end # ClassMethods
  end # Authentication
end # Concerns
