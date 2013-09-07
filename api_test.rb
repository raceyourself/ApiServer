#!/usr/bin/env ruby

require 'oauth2'

puts
puts "============================== Databank client application token tester =============================="
puts
puts

def default_value_or_input(name, default_value)
  puts "#{name}#{ " (Press enter for #{ default_value })" if default_value }: "
  value = $stdin.gets 
  value = default_value if value.chomp.length == 0
  value.chomp.strip
end

client_id = default_value_or_input("Application's client ID", ARGV[0])
secret = default_value_or_input("Application's client secret", ARGV[1])
url = default_value_or_input("Databank url", "http://glassfit.dev")
redirect_uri = default_value_or_input("Redirect URI", 'urn:ietf:wg:oauth:2.0:oob')
locale = default_value_or_input("Locale", "en")
puts 
puts "Setting up client with following data: "
puts "Client ID:       #{client_id}"
puts "Client Secret:   #{secret}"
puts "Databank URL:    #{url}"
puts "Redirect URI:    #{redirect_uri}"
puts "Locale:          #{locale}" if locale
puts 
puts 


@client = OAuth2::Client.new(client_id, secret, site: url)
auth_url = @client.auth_code.authorize_url(redirect_uri: redirect_uri, scope: 'write', locale: locale)

puts "Go here: #{auth_url}"
puts "Then enter the authorization code:"
code = $stdin.gets

token = @client.auth_code.get_token(code.strip, redirect_uri: redirect_uri, scope: 'write', locale: locale)

puts "Got new token: #{ token.inspect }"

loop do
  puts "Press enter to use token"
  $stdin.gets
  puts "Got response: "
  puts token.get('api/1/me').parsed
end

# puts "Got client, issuing account"
# account = token.get('/api/v1/account').parsed
# puts account.inspect

# puts 'Updating name'
# account = token.put('/api/v1/account', body: { user: { firstname: 'Danny', lastname: 'Hawkins' } } )
# puts account.inspect

# puts 'Updating password, enter current password'
# current_password = gets

# #account = token.put('/api/v1/password', body: { user: { password: 'password', password_confirmation: 'password', current_password: current_password} })
# #puts account.inspect

# token = token.refresh!
