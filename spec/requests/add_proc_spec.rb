




require 'spec_helper'

describe 'nurse completes procedure' do
	it 'redirects from login page for ordinary nurse' do
		nurse = Fabricate(:nurse)
    nurse.validator?.should be_false
		login(nurse)
		page.should have_content 'add a procedure'
	end
end
