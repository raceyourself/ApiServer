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

    if self.provider == 'twitter' && headers = data.extra.access_token.response.header
      self.permissions = 'login' if headers['x-access-level'] == 'read'
      self.permissions = 'login,share' if headers['x-access-level'] == 'read-write'
    else
      update_permissions_from_provider()  
    end

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


end
