require 'spec_helper'




describe 'login page' do

	it 'after successful sign in, takes regular nurse to submit procedure page' do
		nurse = Fabricate :nurse
		login nurse
		page.should have_content 'Submit Procedure'
		on_pending_vn_page?.should be_false
	end
	it 'tells nurse that username and password are invalid, when annoyed' do
		nurse = Fabricate :nurse
		nurse.password = ''
		login nurse
		page.should have_content 'Invalid'
	end
	it "takes admin to validator page, if validator (ie validator wins over admin)" do
		nurse = Fabricate :nurse, admin: true, validator: true
		login nurse
		on_pending_vn_page?.should be_true
	end
	it 'takes validating nurse to validation page after successful login' do 
		vn = Fabricate :v_nurse
		login vn
		on_pending_vn_page?.should be_true
	end
	it "takes nurse to a page other than the default page if specified in params" do
		n = Fabricate :nurse
		login n, next_url: home_nurse_path(n)
		page.should have_content 'Home'
	end
	it "tests for the remember me checkbox" do
		n = Fabricate :nurse
		login n, :remember_me
		cookies = Capybara.current_session.driver.browser.current_session
				.instance_variable_get(:@rack_mock_session).cookie_jar.instance_variable_get(:@cookies)

		#clear cookies without expiries (ie session cookies)
		cookies.delete_if {|i| !i.expires}
		cookies.length.should eq 1
	end
end
