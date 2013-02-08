require 'spec_helper'



VALIDATION_CONTENT = 'Pending Validations'

describe 'login page' do
	it 'after successful sigin-in, takes regular nurse to add procedure page' do
		nurse = Fabricate(:nurse)
		login(nurse)
		page.should have_content('add a procedure?')
	end
	it 'tells nurse that username and password are invalid' do
		nurse = Fabricate(:nurse)
		nurse.password = ''
		login(nurse)
		page.should have_content('Invalid')
	end
	it "takes admin to validator page, if validator (ie validator wins over admin)" do
		nurse = Fabricate(:nurse, admin: true, validator: true)
		login(nurse)
		page.should have_content VALIDATION_CONTENT
	end
	it 'takes validating nurse to validation page after successful login' do 
		validator_nurse = Fabricate(:nurse, validator: true)
		login(validator_nurse)
		page.should have_content VALIDATION_CONTENT
	end

end
