




require 'spec_helper'

describe 'nurse completes procedure' do
	it 'redirects from login page for ordinary nurse' do
    nurse = Fabricate(:nurse)
    login(nurse)
    nurse.validator?.should be_false
    page.should have_content 'add a procedure'
  end
  it 'shows happy drop down list', :js => true do
    proc_name = '_____procedure'
    Fabricate :procedure, name: proc_name
    nurse = Fabricate(:nurse)
    login(nurse)
    fill_in 'proc_name', with: '____'
    sleep 1
    page.should have_text proc_name
  end
end
