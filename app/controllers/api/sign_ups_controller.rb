module Api
  class SignUpsController < BaseController

    def create
      errors = {}
      # By code
      invite = Invite.where(:code => params[:invite_code]).first
      # By invited e-mail
      invite = Invite.where(:identity_type => 'email').where(:identity_uid => params[:email]).first unless invite
      # By invited identity 
      # NOTE: authentication[:uid] is provided by client and cannot be trusted.
      authentication = params[:authentication] || {}
      invite = Invite.where(:identity_type => authentication[:provider]).where(:identity_uid => authentication[:uid]).first unless invite
      
      errors[:invite_code] = ['is missing'] unless invite

      if errors.empty?
        profile = params[:profile] || {}
        @user = User.new(
                username: profile[:username],
                name: profile[:name],
                password: params[:password],
                email: params[:email],
                gender: profile[:gender],
                timezone: profile[:timezone],
                profile: profile.except(:username, :name, :image, :gender, :timezone)
        )
        if @user.valid?
          begin
            ActiveRecord::Base.transaction do 
              @user.remote_image_url = profile[:image] if profile[:image].is_a?(String)
              @user.skip_confirmation!
              if authentication.present?
                auth = @user.authentications.build.tap do |a|
                  a.provider = authentication[:provider]
                  a.uid = authentication[:uid]
                end
                auth.update_from_access_token(authentication[:access_token])
                raise ArgumentError, 'Wrong uid supplied in request' unless auth.uid == authentication[:uid]
                auth.save!

                # Update friends list
                case auth.provider
                when 'facebook'
                  FacebookFriendsWorker.perform_async(@user.id)
                when 'twitter'
                  TwitterFriendsWorker.perform_async(@user.id)
                when 'gplus'
                  GplusFriendsWorker.perform_async(@user.id)
                end 
              end
              @user.save!

              # Destroy accepted invite
              invite.destroy if invite
            end
          rescue => e
            logger.error(e.class.name + ": " + e.message)
            logger.debug e.backtrace.join("\n")
            errors[:user] = ["threw exception #{e.class.name}"]
          end
        else
          errors.merge! @user.errors.messages
          errors[:user] = ['is invalid'] if errors.empty?
        end
      end

      if errors.empty?
        expose({:success => true, :user => @user})
      else
        expose({:errors => errors})
      end
    end

  end
end
