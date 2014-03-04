



require 'spec_helper'

describe "Nurse's home page" do

  before(:all) {Fabricate :dept, name: 'Hankerchief Dept'}

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
      page.should have_text '(updated'
    end      
    def check_autoupdate_field *args
      o = args.extract_options!
      fill_in o[:label], with: o[:with]
      click_and_wait_for_ajax
      vn.reload.send(o[:attr]).should eq o[:with]
    end
    def check_client_side_error *args
      o = args.extract_options!
      orig_attrs = vn.attributes
      fill_in o[:label], with: o[:with_bad]
      find('h1').click # click outside field to trigger error
      page.should have_text o[:error]
      # there are errors on the form, so nurse should not have changed in db
      vn.reload
      vn.attributes.should eq orig_attrs

      # valid data should clear the error
      fill_in o[:label], with: o[:with_valid]
      page.should_not have_text o[:error]
      find('h1').click # click outside field to trigger save
      # wait for the save to occur
      page.should have_text '(updated'
      # nurse should be saved with new attributes
      vn.reload
      vn.attributes.should_not eq orig_attrs
    end

    # combine all these into a single test to speed it up
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

      TEST_IMAGE = File.dirname(__FILE__)+'/image.jpeg'
      attach_file 'Image', TEST_IMAGE
      # when we submit a mugshot change, it goes via html.... so there's no ajax and 'updated'
      find('h1').click
      checksum(vn.reload.mugshot).should eq checksum(File.open(TEST_IMAGE, &:read))
    end
    it "shows errors immediately for certain fields", js: true do
      check_client_side_error label: 'Name', with_bad: '', with_valid: 'Florence N', 
                              error: 'This value is required'
      check_client_side_error label: 'Email', with_bad: 'a@b', with_valid: 'a@b.com', 
                              error: 'This value should be a valid email'
    end
    it "doesn't show checkbox to receive mail, unless validator" do
      visit_home Fabricate :nurse
      page.should have_no_css('#wants_mail')
    end
    it "shows 'updating' while changes are being saved", js: true do
      check 'Receive daily emails?'
      page.should have_text('updating')
      # Wait till image disappears.
      page.should have_text('updated')
    end
    it "image can't be excessively large"
  end

end
