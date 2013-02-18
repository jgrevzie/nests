



require 'csv'
require 'fabrication'

def fabricate_nurses
	Fabricate :v_nurse, username: 'heather', first_name: 'Heather'
	Fabricate :nurse, username: 'nancy', first_name: 'Nancy'
	Fabricate :v_nurse, username: 'sheila', first_name: 'Sheila'
	5.times { Fabricate :nurse_5_procs }
end

def load_csv
	db_dir = ENV['DIR'] || File.join(Rails.root, 'db')

	open(db_dir + '/seeds.rb', 'w') do |seeds|

		csv = CSV.foreach(db_dir+'/procedures.csv', :headers => true) do |row|
			create_proc = %Q/Procedure.create(:name => "#{row['Name']}", :abbrev => "#{row['Abbrev']}", :options => "#{row['Options']}")/
			seeds.puts create_proc
		end
	end
end

namespace :nest do

	desc 'reset database with seed data from csv'
	task :reset => 'db:mongoid:drop' do
		Rake::Task['db:seed'].invoke
		load_csv
		fabricate_nurses
	end

end