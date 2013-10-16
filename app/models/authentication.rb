class Authentication < ActiveRecord::Base
  # associations
  belongs_to :user


  def update_from_omniauth(data)
    self.provider_data        = data.to_yaml
    self.email                = data.info.email if data.info && data.info.email

    if creds = data.credentials
      self.token              = creds.token if creds.token
      self.token_secret       = creds.secret if creds.secret
      self.refresh_token      = creds.refresh_token if creds.refresh_token
      self.token_expires      = creds.expires || true
      self.token_expires_at   = Time.at(creds.expires_at) if creds.expires_at
    end

  end

end
