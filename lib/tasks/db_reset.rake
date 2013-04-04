




require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :nest do

	desc 'reset database with seed data from csv'
	task reset: :environment do
		Mongoid.purge!
		SpreadsheetLoader.load_procs CATHLAB_XLS
		SpreadsheetLoader.load_nurses(CATHLAB_XLS, Fabricate(:dept, name: 'CathLab')) \
			if Rails.env.development? || Rails.env.production?
		Nurse.all.each {|n| 50.times { n.completed_procs << Fabricate(:random_completed_proc) }}
	end

	task show_env: :environment do
		p ENV
	end

end #namespace
