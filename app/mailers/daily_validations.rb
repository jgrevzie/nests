class DailyValidations < ActionMailer::Base
  default from: "cathtraq.mailer@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.daily_validations.send_pendings.subject
  #
  add_template_helper(ApplicationHelper)

  def protect_against_forgery?
      false
  end

  def send_pendings(nurse)
    @nurse = nurse

    mail to: @nurse.email, subject: "Daily validations"
  end
end
