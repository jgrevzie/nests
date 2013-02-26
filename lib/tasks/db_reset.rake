



require 'csv'
require 'fabrication'

DB_DIR = ENV['DIR'] || File.join(Rails.root, 'db')

def clean(s)
	s ? s.downcase.gsub(/[^a-z]/, '') : ''
end

def load_procs(seeds_file)
	csv = CSV.foreach(DB_DIR+'/procedures.csv', :headers => true) do |row|
		create_proc = %Q/Procedure.create(:name => "#{row['Name']}", :abbrev => "#{row['Abbrev']}", :options => "#{row['Options']}")/
		seeds_file.puts create_proc
	end
end
def load_nurses(seeds_file)
	csv = CSV.foreach(DB_DIR+'/nurses.csv', headers: true) do |row|
		username = row['username'] || clean(row['first_name'])[0] + clean(row['last_name'])
		is_validator = row['validator'].downcase.include? 'y' if row['validator']
		email = row['email'] || "#{clean(row['first_name'])}.#{clean(row['last_name'])}@svpm.org.au"
		create_nurse = %Q/Nurse.create(first_name: "#{row['first_name']}", last_name: "#{row['last_name']}", username: "#{username}", password: 'password', validator: "#{is_validator}", email: "#{email}")/
		seeds_file.puts create_nurse
	end


end

namespace :nest do

	desc 'reset database with seed data from csv'
	task :reset => 'db:mongoid:drop' do
		open(DB_DIR + '/seeds.rb', 'w') do |seeds|
			load_procs seeds
			load_nurses seeds if Rails.env.development?
		end
		Rake::Task['db:seed'].invoke
		
		if Rails.env.development?
			Fabricate :nurse, username: 'nancy'
			#Give some of the nurses pending completed procs
			Nurse.all.to_ary.sample(10).each do |n|
				5.times { n.completed_procs << Fabricate(:random_completed_proc) }
			end
		end
	end

end
