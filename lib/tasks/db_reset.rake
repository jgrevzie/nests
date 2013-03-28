




require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :nest do

	desc 'reset database with seed data from csv'
	task reset: :environment do
		Mongoid.purge!
		Procedure.load_procs_from_spreadsheet PROC_FILE
		Nurse.load_nurses_from_spreadsheet(NURSE_FILE) \
			if Rails.env.development? || Rails.env.production?
	end

	task show_env: :environment do
		p ENV
	end

end #namespace
