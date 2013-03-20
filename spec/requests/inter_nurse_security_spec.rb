




require 'spec_helper'



describe "security checks for nurse access" do
  it "don't let ordinary nurse access another nurse's home page" do
    n1 = login Fabricate :nurse
    n2 = Fabricate :nurse
    visit home_nurse_path n2
    page.status_code.should eq Rack::Utils::SYMBOL_TO_STATUS_CODE[:forbidden]
  end
  it "let validating nurses sneak all over the damn show" do
    n1 = login Fabricate :v_nurse
    n2 = Fabricate :nurse
    visit home_nurse_path n2
    page.should have_text 'Home'
    page.should have_text n2.first_name
  end
end