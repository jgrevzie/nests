




require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :nest do

	desc 'reset database with seed data from csv'
	task reset: :environment do
		Mongoid.purge!
		SpreadsheetLoader.load_dept DB_DIR+'/CathLab.xls'
		SpreadsheetLoader.load_dept DB_DIR+'/Theatre.xls'
		Nurse.all.each {|n| 50.times { n.completed_procs << Fabricate(:random_completed_proc) }} \
			if Rails.env.development?
	end

	task show_env: :environment do
		p ENV
	end

end #namespace
