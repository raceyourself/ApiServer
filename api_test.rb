#!/usr/bin/env ruby
require 'oauth2'

puts
puts "============================== Glassfit client application token tester =============================="
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
puts 
puts "Setting up client with following data: "
puts "Client ID:       #{client_id}"
puts "Client Secret:   #{secret}"
puts "Glassfit URL:    #{url}"
puts "Redirect URI:    #{redirect_uri}"
puts 


@client = OAuth2::Client.new(client_id, secret, site: url)
auth_url = @client.auth_code.authorize_url(redirect_uri: redirect_uri)

puts "Go here: #{auth_url}"
puts "Then enter the authorization code:"
code = $stdin.gets

token = @client.auth_code.get_token(code.strip, redirect_uri: redirect_uri)

puts "Got new token: #{ token.inspect }"

loop do
  puts "Press enter to use token"
  $stdin.gets
  puts "Got response: "
  puts token.get('api/1/me').parsed
end
