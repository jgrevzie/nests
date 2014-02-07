source 'https://rubygems.org'





ruby '2.1.0'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  #gem 'execjs', '1.4.0'
  gem 'uglifier'#, '2.1.1'
  gem 'jquery-rails'#, '3.0.0'
  gem 'rb-fsevent'#, '~> 0.9.1'
#  gem "teabag"
end

# just putting these here to deal with dependency issues
#gem 'arel', '3.0.2'
#gem 'coderay', '1.0.9'
#gem 'coffee-script-source', '1.6.2'
#gem 'diff-lcs', '1.2.4'
#gem 'ffi', '1.8.1'
#gem 'listen', '1.1.6'
#gem 'childprocess'#, '0.3.9'

gem 'sass-rails'#,   '~> 3.2.3'
gem 'coffee-rails'#, '~> 3.2.1'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem "mongoid"#, '4.0.0.beta1', github: 'mongoid/mongoid'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'thin'#, '1.5.1'
gem 'validates_timeliness'#, git: 'git://github.com/adzap/validates_timeliness.git', branch: 'rails4'
gem "fabrication"#, '2.7.2'
gem 'haml'#, '4.0.3'
gem 'spreadsheet'
gem "rspec-rails", :group => [:test, :development]
gem 'pry'
gem 'bson_ext'
gem 'daemon_controller'

#gem 'protected_attributes'
gem 'client_side_validations'#, '3.2.5'
gem 'client_side_validations-mongoid'

group :test do
  gem "capybara"#, '2.0.3'
  gem 'guard'#, '1.8.0'
  gem "guard-rspec"#, '3.0.1'
  gem "poltergeist"
  gem 'capybara-webkit'#, '~> 0.14.2'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end
