



require 'csv'
require 'fabrication'

DB_DIR = ENV['DIR'] || File.join(Rails.root, 'db')

class String
	def lc_alpha; self ? self.downcase.gsub(/[^a-z]/, '') : '' end
end		

def load_procs(seeds_file)
	csv = CSV.foreach(DB_DIR+'/procedures.csv', 
										headers: true, 
										converters: lambda {|field| field.nil? ? "" : field}) do |row|
		p row
		create_proc = %Q/Procedure.create(name: "#{row['name'].strip}", 
										abbrev: "#{row['abbrev'].strip}", 
										options: "#{row['options'].gsub(', ',',').strip}")/
		seeds_file.puts create_proc
	end
end
def load_nurses
	csv = CSV.foreach(DB_DIR+'/nurses.csv', headers: true) do |row|
		row['username'] = 
			row['first_name'][0].lc_alpha + row['last_name'].lc_alpha unless row['username']
		row['validator'] = row['validator'] ? row['validator'].downcase.include?('y') : false
		row['email'] = 
			"#{row['first_name'].lc_alpha}.#{row['last_name'].lc_alpha}@svpm.org.au" unless row['email']
		row['password'] = 'password'

		n = Fabricate :nurse, row.to_hash # CSV::Row needs to be converted to hash
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
