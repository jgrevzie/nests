




require 'simplecov'
SimpleCov.start 'rails'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include Capybara::DSL

  config.before :each do
    reset_db unless example.metadata[:reset_db]==false
    Mail::TestMailer::deliveries.clear
  end

end

Capybara.javascript_driver = :webkit

def reset_db
  clear_db
  SpreadsheetLoader::load_procs CATHLAB_XLS
end

def clear_db
  Mongoid::Sessions.default.collections.select {|c| c.name !~ /system/ }.each(&:drop)
end

def login(nurse, *args)
  options = args.extract_options!
  visit login_path(options)
  fill_in 'username', with: nurse.username
  fill_in 'password', with: nurse.password
  check 'Remember me' if args.include? :remember_me

  #click button unless args have :no_submit
  click_button 'Login' unless args.include? :no_submit
  return nurse
end

def on_pending_vn_page?
  page.has_css?('.header h1', text: PENDING_VALIDATIONS_HEADER)
end

def visit_home nurse
  login nurse
  visit home_nurse_path nurse
end

