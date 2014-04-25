class Authentication < ActiveRecord::Base
  # associations
  belongs_to :user


  def update_from_omniauth(data)
    self.provider_data        = nil # data.to_yaml
    self.email                = data.info.email if data.info && data.info.email

    if creds = data.credentials
      self.token              = creds.token if creds.token
      self.token_secret       = creds.secret if creds.secret
      self.refresh_token      = creds.refresh_token if creds.refresh_token
      self.token_expires      = creds.expires || true
      self.token_expires_at   = Time.at(creds.expires_at) if creds.expires_at
    end

    if self.provider == 'twitter'
      self.permissions = 'login'
      self.permissions = 'login,share' if data['x-access-level'] == 'read-write'
    else
      update_permissions_from_provider()  
    end

  end

  def update_from_access_token(token)
    self.token = token
    self.token_secret = nil
    self.token_expires = false
    self.token_expires_at = nil

    update_permissions_from_provider()
  end

  def update_permissions_from_provider
    perms = []

    case self.provider
    when 'facebook'
      graph = Koala::Facebook::API.new(self.token)
      fb_permissions = graph.get_connections('me','permissions')
      perms << 'login'
      perms << 'share' if fb_permissions[0]['publish_actions'].to_i == 1

    when 'twitter'
      # Set from headers when authorizing

    when 'gplus'
      perms << 'login'
      perms << 'share' # Assume addActivity permissions since we can't check
    end

    self.permissions = perms.join(',')
  end

   def self.exchange_access_token(provider, token)
    server_token = nil

    case provider
    when 'facebook'
      oauth = Koala::Facebook::OAuth.new(CONFIG[:facebook][:client_id], CONFIG[:facebook][:client_secret])
      server_token = oauth.exchange_access_token_info(token)
    end

    server_token
  end 

end
