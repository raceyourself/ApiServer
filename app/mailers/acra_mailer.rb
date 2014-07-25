class AcraMailer < ActionMailer::Base
  default to:   'crashreport@raceyourself.com',
          from: 'api@raceyourself.com'

  def report_crash(user, report)
    @user = user
    @report = report
    mail(subject: 'Crash report from ' + user.to_s)
  end
end
