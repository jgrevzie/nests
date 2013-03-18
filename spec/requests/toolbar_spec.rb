require 'spec_helper'



describe "toolbar" do
  describe "(Send Mail)"
    it "when clicked, sends that user a mail" do
      login Fabricate :v_nurse
      click_on 'Send Mail'
      Mail::TestMailer.deliveries.length.should eq 1
    end
    it "doesn't appear, unless user is validator" do
      login Fabricate :nurse
      find('.left').should have_no_link 'Send Mail'
    end
end