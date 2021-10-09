# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) {|repo_name| 'https://github.com/#{repo_name}' }

# gem 'rails'

gem 'discordrb', '3.4.2', git: 'https://github.com/shardlab/discordrb'

gem 'standalone_migrations'

gem 'rake'
gem 'sqlite3'

gem 'activerecord'
# gem 'activesupport'

gem 'rerun'

gem 'colorize'

group :development do
  gem 'capistrano', '~> 3.10', require: false
  gem 'capistrano-rails', '~> 1.3', require: false
  gem 'capistrano-bundler', '~> 2.0'

  gem 'ed25519', '~> 1.2'
  gem 'bcrypt_pbkdf', '~> 1.0'
end