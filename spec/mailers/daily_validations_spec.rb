require "spec_helper"

describe DailyValidations do
  describe "send_pendings" do
    let(:mail) { DailyValidations.send_pendings }

    it "renders the headers" do
      # mail.subject.should eq("Send pendings")
      # mail.to.should eq(["to@example.org"])
      # mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      # mail.body.encoded.should match("Hi")
    end
  end

end
