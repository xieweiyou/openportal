require "bundler/capistrano"
require "rvm/capistrano"
#require "capistrano/ext/multistage"

require "rvm/capistrano"

set :rvm_ruby_string, :local              # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs

before 'deploy:setup', 'rvm:install_rvm'  # install/update RVM
before 'deploy:setup', 'rvm:install_ruby' # install Ruby and create gemset, OR:
# before 'deploy:setup', 'rvm:create_gemset' # only create gemset


server "ec2-54-200-52-60.us-west-2.compute.amazonaws.com", :web, :app, :db, primary: true

set :application, "openportal"
set :user, "ubuntu"
set :deploy_to, "/home/ubuntu/apps/openportal"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm_username, "ubuntu"
set :scm, "git"
set :repository,  "git@github.com:openportal/openportal.git"
set :branch, "master"

#set :stages, ["staging", "production"]
#set :default_stage, "staging"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:keys] = ["/home/meowmixer/Desktop/meowmixerkey.pem"]

#after "deploy", "deploy:cleanup" # keep only the last 5 releases

=begin
namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :setup_config, roles: :app do
    require 'debugger'
    debugger
    run "#{sudo} ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    #sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    run "#{sudo} ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    #sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless 'git rev-parse HEAD' == 'git rev-parse origin/master'
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run 'git push' to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end


# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
=end
