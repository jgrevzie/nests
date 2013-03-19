require "spec_helper"



def check_mail_content(mail, *args)
  mail.parts.length.should eq 2
  mail.parts[0].content_type.should match 'text/plain'
  mail.parts[0].body.decoded.should match "You have #{CP.pending.count} pending validation/s"

  mail.parts[1].content_type.should match 'html'
  # Most testing of content is done in pendings validations spec.
  mail.body.encoded.should match "If your email client can't display"
  mail.body.encoded.should match /http:.*pending_validations/
end

describe DailyValidations do

  let(:vn) { Fabricate :v_nurse, email: 'nurse@example.org', wants_mail: true }

  describe "#pending_validations_mail" do
    let(:mail) { DailyValidations.pending_validations_mail vn }

    # Grab some pending validations.
    before(:each) { Fabricate :nurse_5_pendings }

    it "renders the headers" do
      mail.subject.should eq("Daily validations")
      mail.to.should eq([vn.email])
      mail.from.should eq ["#{ENV['MAIL_USER']}@gmail.com"]
    end
    it "renders the body" do
      check_mail_content mail
    end

  end # #pending_validations_mail

  describe "Nurse#send_all_pending_validation_mails" do
    it "doesn't send mail to non validators or nurses who have chosen not receive mail" do
      Fabricate :v_nurse, wants_mail: true
      n = Fabricate :nurse
      4.times { Fabricate :v_nurse }

      Nurse.send_all_pending_validation_mails
      Mail::TestMailer.deliveries.length.should eq 1
    end
    it "sends mail to validators that have chosen to receive mail" do 
      10.times { Fabricate :v_nurse, wants_mail: true}

      Nurse.send_all_pending_validation_mails
      Mail::TestMailer.deliveries.length.should eq 10
    end
    # Once had bug where mail to one nurse had content, mail to all nurses had no content.
    it "sends mail with appropriate content" do 
      Fabricate :v_nurse, wants_mail: true
      Fabricate :nurse_5_pendings
      Nurse.send_all_pending_validation_mails
      Mail::TestMailer.deliveries.length.should eq 1
      mail = Mail::TestMailer.deliveries.pop
      check_mail_content mail
    end
  end  
end
