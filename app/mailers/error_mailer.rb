class ErrorMailer < ActionMailer::Base
  default to:   'errors@raceyourself.com',
          from: 'api@raceyourself.com'

  def sidekiq_error(ex, ctx_hash)
    @ex = ex
    @ctx_hash = ctx_hash
    mail(subject: 'Sidekiq job failed')
  end
end
