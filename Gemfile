# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 8.0.2'
# Rails 8.0 ActiveSupport passes `quirks_mode:` to JSON.generate/parse,
# which was removed in json 3.x.
gem 'json', '~> 2.7'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.6'
# Use Puma as the app server
gem 'puma', '~> 6.6'

# Asset pipeline: sprockets + libsass (bootstrap 4 needs sassc), terser for JS.
gem 'sassc-rails'
gem 'sprockets-rails'
gem 'terser'

gem 'activeadmin', '~> 3.3'
gem 'devise', '~> 4.9'

gem 'auto_strip_attributes', '~> 2.6'
# Bootstrap 4 markup is used throughout the views; 4.6.x is the last
# compatible release. Do not jump to 5.x without updating the views.
gem 'bootstrap', '~> 4.6.2'
gem 'jquery-rails', '~> 4.6'
# Canonical-host redirect middleware, wired in config.ru via CANONICAL_HOST.
gem 'rack-canonical-host'
gem 'scenic', '~> 1.8'

group :development, :test do
  gem 'rubocop', require: false
  # Call 'debugger' anywhere in the code to stop execution and get a debugger console
  gem 'debug', platforms: %i[mri windows]
  # Adds support for Capybara system testing
  gem 'capybara', '~> 3.40'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
end
