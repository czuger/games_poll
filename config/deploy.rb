# config valid for current version and patch releases of Capistrano
lock '~> 3.16.0'

set :application, 'games_poll'
set :repo_url, 'git@github.com:czuger/games_poll.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, :main

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/home/webapp/ruby/games_poll'

# set :rbenv_custom_path, '/usr/local/rbenv'
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_type, :user
set :rbenv_prefix, '/usr/bin/rbenv exec'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml'
append :linked_files, 'config/bot.json', 'db/production.sqlite3'

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'
append :linked_dirs, 'log'

# Default value for default_env is {}
# set :default_env, { path: '/opt/ruby/bin:$PATH' }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 10

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

task :restart_bot do
  on roles :all do

    execute 'supervisorctl restart games_poll'
    execute 'supervisorctl restart games_poll_staging'
  end
end

after 'deploy:finished', :restart_bot
