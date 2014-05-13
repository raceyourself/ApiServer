module Api
  class SignUpsController < BaseController

    def create
      errors = {}
      # By code
      invite = Invite.where(:code => params[:invite_code]).first
      # By invited e-mail
      invite = Invite.where(:identity_type => 'email').where(:identity_uid => params[:email]).first unless invite
      # By invited identity
      authentication = params[:authentication] || {}
      invite = Invite.where(:identity_type => authentication[:provider]).where(:identity_uid => authentication[:uid]).first unless invite
      
      errors[:invite_code] = ['missing'] unless invite

      if errors.empty?
        profile = params[:profile] || {}
        ActiveRecord::Base.transaction do
          @user = User.new(
                  username: profile[:username],
                  name: profile[:name],
                  password: params[:password],
                  email: params[:email],
                  image: profile[:image],
                  gender: profile[:gender],
                  timezone: profile[:timezone],
                  profile: profile.except(:username, :name, :image, :gender, :timezone)
          )
          if @user.valid?
            begin
              @user.skip_confirmation!
              if authentication.present?
                auth = @user.authentications.build.tap do |a|
                  a.provider = authentication[:provider]
                  a.uid = authentication[:uid]
                end
                auth.update_from_access_token(server_token)
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
      end

      if errors.empty?
        expose({:success => true, :user => @user})
      else
        expose({:errors => errors})
      end
    end

  end
end
