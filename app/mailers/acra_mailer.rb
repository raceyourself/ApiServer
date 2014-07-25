class AcraMailer < ActionMailer::Base
  default to:   'crashreport@raceyourself.com',
          from: 'api@raceyourself.com'

  def report_crash(user, report)
    @user = user
    @report = report
    mail(subject: 'Crash reprot from ' + user.to_s)
  end
end
