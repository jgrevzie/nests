



require 'csv'

namespace :nest do

	desc 'reset database with seed data from csv'
	task :reset => 'db:mongoid:drop' do

		db_dir = ENV['DIR'] || File.join(Rails.root, 'db')

		open(db_dir + '/seeds.rb', 'w') do |seeds|
			
			csv = CSV.foreach(db_dir+'/procedures.csv', :headers => true) do |row|
				create_proc = %Q/Procedure.create(:name => "#{row['Name']}", :abbrev => "#{row['Abbrev']}", :options => "#{row['Options']}")/
				seeds.puts create_proc
			end

			Nurse.create(:username => "jackie",
				:first_name => "Jackie",
				:last_name => "Peyton",
				:password_digest => BCrypt::Password.create("password"))
		end
		Rake::Task['db:seed'].invoke
	end

end