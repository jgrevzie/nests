



require 'csv'
require 'fabrication'

DB_DIR = ENV['DIR'] || File.join(Rails.root, 'db')

def clean(s)
	s ? s.downcase.gsub(/[^a-z]/, '') : ''
end

def load_procs(seeds_file)
	csv = CSV.foreach(DB_DIR+'/procedures.csv', :headers => true) do |row|
		create_proc = %Q/Procedure.create(:name => "#{row['name']}", :abbrev => "#{row['abbrev']}", :options => "#{row['options']}")/
		seeds_file.puts create_proc
	end
end
def load_nurses
	csv = CSV.foreach(DB_DIR+'/nurses.csv', headers: true) do |row|
		row['username'] = clean(row['first_name'][0]) + clean(row['last_name']) unless row['username']
		row['validator'] = row['validator'] ? row['validator'].downcase.include?('y') : false
		row['email'] = 
			"#{clean(row['first_name'])}.#{clean(row['last_name'])}@svpm.org.au" unless row['email']
		row['password'] = 'password'

		n = Fabricate :nurse, row.to_hash
		50.times { n.completed_procs << Fabricate(:random_completed_proc) }

	end
end

namespace :nest do

	desc 'reset database with seed data from csv'
	task reset: :environment do
		Mongoid.purge!
		open(DB_DIR + '/seeds.rb', 'w') { |seeds| load_procs seeds }
		Rake::Task['db:seed'].invoke		
		load_nurses if Rails.env.development? || Rails.env.production?
	end #task

	task show_env: :environment do
		p ENV
	end

end #namespace
