class DailyValidations < ActionMailer::Base
  default from: "cathtraq.mailer@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.daily_validations.send_pendings.subject
  #
  def send_pendings
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
