require 'mandrill'

class MandrillMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  MESSAGE_DEFAULTS = {
  }

  def confirmation_instructions(record, token, opts={})
    mandrill = Mandrill::API.new(CONFIG[:mandrill][:api_key])
    result = mandrill.messages
                     .send_template('confirmation-instructions', [
                                      # Template content
                                   ], MESSAGE_DEFAULTS.merge({
                                      'to' => [
                                        { 'email' => record.email }
                                      ],
                                      'global_merge_vars' => [
                                        { 'name' => 'CONFIRMATION_URL', 
                                          'content' => confirmation_url(record, :confirmation_token => token)
                                        }
                                      ]
                                   })
    )
  end

  def reset_password_instructions(record, token, opts={})
    mandrill = Mandrill::API.new(CONFIG[:mandrill][:api_key])
    result = mandrill.messages
                     .send_template('reset-password-instructions', [
                                      # Template content
                                   ], MESSAGE_DEFAULTS.merge({
                                      'to' => [
                                        { 'email' => record.email }
                                      ],
                                      'global_merge_vars' => [
                                        { 'name' => 'RESET_PASSWORD_URL', 
                                          'content' => edit_password_url(record, :reset_password_token => token)
                                        }
                                      ]
                                   })
    )
  end

  def unlock_instructions(record, token, opts={})
    mandrill = Mandrill::API.new(CONFIG[:mandrill][:api_key])
    result = mandrill.messages
                     .send_template('unlock-instructions', [
                                      # Template content
                                   ], MESSAGE_DEFAULTS.merge({
                                      'to' => [
                                        { 'email' => record.email }
                                      ],
                                      'global_merge_vars' => [
                                        { 'name' => 'UNLOCK_URL', 
                                          'content' => unlock_url(record, :unlock_token => token)
                                        }
                                      ]
                                   })
    )
  end
end
