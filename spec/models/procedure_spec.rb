require 'spec_helper'




describe 'DatabaseSeeds' do
	it 'checks that there are procs seeded in the database' do
		Procedure.count.should > 0
	end
end