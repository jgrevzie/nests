




require 'spec_helper'

describe 'AddingProc' do
	it 'links an existing proc to a completed_proc' do
		nurse = Fabricate(:nurse)
		login(nurse)
		visit add_procedure_nurse_path(nurse)
		page.should have_content 'add a procedure'
	end
end