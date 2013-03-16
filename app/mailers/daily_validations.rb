class DailyValidations < ActionMailer::Base
  default from: "cathtraq.mailer@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.daily_validations.send_pendings.subject
  #



    
  #Just used to turn off forgery protection.
  add_template_helper MailHelper

  def send_pendings
    Nurse.where(validator: true, wants_mail: true).each { |n| send_pendings_to_nurse(n).deliver }
  end

  def send_pendings_to_nurse(nurse)
    puts "sending mail to nurse #{nurse.username} (#{nurse.email})"
    @nurse = nurse

    mail to: @nurse.email, subject: "Daily validations"
  end
end
