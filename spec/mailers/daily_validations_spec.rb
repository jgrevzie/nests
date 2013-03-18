require "spec_helper"




describe DailyValidations do

  let(:vn) { Fabricate :v_nurse, email: 'nurse@example.org', wants_mail: true }

  describe "send_pendings_to_nurse" do
    let(:mail) { DailyValidations.send_pendings_to_nurse vn }

    before :each do
      # Grabs some pending validations.
      Fabricate :nurse_5_pendings
    end

    it "renders the headers" do
      mail.subject.should eq("Daily validations")
      mail.to.should eq([vn.email])
      mail.from.should eq ["#{ENV['MAIL_USER']}@gmail.com"]
    end

    it "renders the body" do
      mail.parts.length.should eq 2
      mail.parts[0].content_type.should match 'text/plain'
      mail.parts[0].body.decoded.should match 'You have 5 pending validation/s today.'
      
      mail.parts[1].content_type.should match 'html'
      # Most testing of content is done in pendings validations spec.
      mail.body.encoded.should match "If your email client can't display"
      mail.body.encoded.should match pending_validations_nurse_url vn
    end
  end
  describe "send_pendings" do
    it "doesn't send mail to non validators or nurses who have chosen not receive mail" do
      vn
      n = Fabricate :nurse
      vn_no_mail = Fabricate :v_nurse
      DailyValidations.send_pendings
      Mail::TestMailer.deliveries.length.should eq 1
    end
  end

end
