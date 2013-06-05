



namespace :nest do

	desc 'reset database with seed data from csv'
	task reset: :environment do
		Mongoid.purge!
		puts "Loading spreadhseets"
		File.open(DB_DIR+'/CathLab.xls') {|io| DeptSpreadsheet.load_dept io}
		puts "Making procs"
		Nurse.all.each {|n| 50.times { n.completed_procs << Fabricate(:random_completed_proc) }} \
			if Rails.env.development?
	end

	task show_env: :environment do
		p ENV
	end

end #namespace
