require 'bundler/capistrano'

default_run_options[:pty] = true  # Must be set for the password prompt
                                  # from git to work
set :application, "glassfit"
set :deploy_to, File.join("", "var", "www", "vhosts", application)
set :repository,  "git@github.com:glassfit/GFAuthenticate.git"
set :scm, "git"
set :user, "deployer"  # The server's user for deploys

set :branch, "develop"
set :deploy_via, :remote_cache

set :ssh_options, { forward_agent: true }

role :web, "glassfit.dannyhawkins.co.uk"                          # Your HTTP server, Apache/etc
role :app, "glassfit.dannyhawkins.co.uk"                         # This may be the same as your `Web` server
role :db,  "glassfit.dannyhawkins.co.uk", primary: true # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end