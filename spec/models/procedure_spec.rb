require 'spec_helper'





describe 'Procedure' do
  describe 'database seeds' do
  	it 'there are procs seeded in the database' do
  		Procedure.count.should > 0
  	end
  end




  describe '::load_procs_from_spreadsheet(file_name)'
end
