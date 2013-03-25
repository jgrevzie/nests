require 'spec_helper'



describe "application layout" do
  describe "(toolbar)" do
    describe "'Send Mail' link" do
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
  end
  describe "Footer" do
    let(:footer_text) { find('.footer').text }
    it "displays name of logged in nurse" do
      n = login Fabricate :nurse
      footer_text.should match /#{n.first_name} #{n.last_name}/
    end
    it "indicates if nurse is a validator" do 
      vn = login Fabricate :v_nurse
      footer_text.should match /valid/
    end
    it "is empty if nobody is logged in" do
      visit login_path
      footer_text.should be_empty
    end
  end
end