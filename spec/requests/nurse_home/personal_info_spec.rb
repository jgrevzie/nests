



require 'spec_helper'

describe "Nurse's home page", reset_db: false do

  before(:all) {
    clear_db
    dept = Fabricate :dept, name: 'Hankerchief Dept'
  }

  it "shows title for signed in nurse" do
    visit_home n=Fabricate(:nurse)
    page.should have_text 'Home'
    page.should have_text n.first_name
  end
  #Fragile?  Needs something to check z-index issues (have already shown up as bugs).
  it "closes top accordion if header is clicked" do
    visit_home n=Fabricate(:nurse)
    find('#topHeader').click
    find('#topHeader').should_not have_text 'Designation'
  end
  it "on_pending_vn_page? won't detect 'Pending Validations' on horizontal toolbar" do
    visit_home Fabricate(:v_nurse)
    on_pending_vn_page?.should be_false
  end

  describe "(personal info)", js: true do
    let(:vn) {Fabricate(:v_nurse)}
    before(:each) { visit_home vn }
    def click_and_wait_for_ajax
      # Click on something outside of auto-update fields.
      find('h1').click
      # Wait for the spinner to disappear.
      page.has_no_css?('#topHeader img', visible: true).should be_true
    end      
    def check_autoupdate_field *args
      o = args.extract_options!
      fill_in o[:label], with: o[:with]
      click_and_wait_for_ajax
      vn.reload.send(o[:attr]).should eq o[:with]
    end

    it "updates if fields are changed" do
      check_autoupdate_field label: 'Name', with: 'Naughty Nurse', attr: :name
      check_autoupdate_field label: 'Designation', with: 'Test Desig', attr: :designation

      # Choose dept that's not already selected.
      new_dept = (all('option').map {|i| i[:value]} - [vn.dept.id.to_s]).sample
      find("option[value='#{new_dept}']").select_option
      click_and_wait_for_ajax
      vn.reload.dept.id.to_s.should eq new_dept

      check_autoupdate_field label: 'nurse_comments', with: 'Hello nurse!', attr: :comments
      check_autoupdate_field label: 'Email', with: 't@example.com', attr: :email

      check 'Receive daily emails?'
      click_and_wait_for_ajax
      vn.reload.wants_mail.should be_true
    end
    it "doesn't show checkbox to receive mail, unless validator" do
      visit_home Fabricate :nurse
      page.should have_no_css('#wants_mail')
    end
    it "shows spinning wheel while changes are being made", js: true do
      check 'Receive daily emails?'
      find('#topHeader img').visible?.should be_true
      # Wait till image disappears.
      page.has_no_css?('#topHeader img', visible: true).should be_true
    end
  end

end
