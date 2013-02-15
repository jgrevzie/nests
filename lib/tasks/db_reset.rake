



require 'csv'
require 'fabrication'

def fabricate_nurses
	heather = Fabricate :head_nurse_5_subs, username: 'heather', first_name: 'Heather'
	heather.validatees << Fabricate(:nurse, username: 'paul', first_name: 'Paul')
	Fabricate :head_nurse_5_subs, username: 'sheila', first_name: 'Sheila'
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