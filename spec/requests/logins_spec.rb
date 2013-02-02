require 'spec_helper'




describe 'RegularNurseSignsIn' do
	it 'takes regular nurse to add procedure page' do
		nurse = Fabricate(:nurse)
		visit login_path
		fill_in 'username', :with => nurse.username
		fill_in 'password', :with => nurse.password
		click_button 'Login'
		page.should have_content('add a procedure?')
	end
end
