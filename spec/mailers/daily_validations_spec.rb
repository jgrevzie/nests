require "spec_helper"

describe DailyValidations do
  describe "send_pendings" do
    let(:mail) { DailyValidations.send_pendings }

    it "renders the headers" #do
      # mail.subject.should eq("Send pendings")
      # mail.to.should eq(["to@example.org"])
      # mail.from.should eq(["from@example.com"])
    #end

    it "renders the body" #do
      # mail.body.encoded.should match("Hi")
    #end
    it "sends mail to individual nurse if click on toolbar"
    it "doesn't send mail to non validators or nurses who have chosen not receive mail"
    it "includes table with appropriate links"
    it "sends text based mail"
    it "includes link for disfunctional clients"
    it "includes some kind of useful subject line"
  end

end
