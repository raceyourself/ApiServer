class Invite < ActiveRecord::Base
  include Concerns::UserRecord
  belongs_to :identity, :foreign_key => [:identity_type, :identity_uid] # may be null (code FFA)
  
  def expired?
    return expires_at != nil && Time.now > expires_at
  end

  def used?
    return used_at != nil
  end

  def merge
    invite = Invite.find(self.code)
    if invite && !invite.used? && self.identity_type.present? && self.identity_uid.present?
      invite.identity_type = self.identity_type
      invite.identity_uid = self.identity_uid
      invite.used_at = Time.now
      invite.expires_at = self.expires_at # TODO: max 7 days?
      invite.save!
    end
    invite
  end

  def self.generate_for(user)
    max_invites = Configuration.for(user, '_internal')[:configuration]['max_invites'] || 0

    while user.generated_invites < max_invites
      loop do
        user = User.find(user.id) # Refresh user
        break if user.generated_invites >= max_invites
        random_token = SecureRandom.urlsafe_base64(nil, false)
        begin
          # Create invite
          invite = Invite.create!(code: random_token, user_id: user.id)
          # Verify count
          User.increment_counter(:generated_invites, user.id) # Atomic increment
          user = User.find(user.id)
          if user.generated_invites > max_invites # Race condition
            User.decrement_count(:invited, user.id)
            invite.destroy!
            # Retry while loop
            user = User.find(user.id)
            break
          end
        rescue ActiveRecord::RecordNotUnique
          # Remove expired invite
          invite = Invite.find(random_token)
          invite.destroy if invite.expired?
          # Continue loop
        end
      end
    end

    Invite.where(user_id: user.id).where('expires_at IS NULL or expires_at < ?', Time.now)
  end

end
