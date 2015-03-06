require 'pry'
require 'sinatra'

require_relative './lib/sequenceserver.rb'



path = ''

env   = :production

if ENV["RACK_ENV"] == 'development' || ENV["RACK_ENV"] == 'test' 
    env   = :development
    path  = File.expand_path(File.dirname(__FILE__))
  else
    set :bin_dir, '/home/app'
    path = '/home/app/SintraServer'
end


set :root, path
set :views, path + '/views'
set :public_dir,  path + '/public'
set :run, false
set :environment, env #:production
set :raise_errors, true
set :database_dir, "#{settings.public_dir}/blast_data"
enable :logging, :dump_errors



SequenceServer.init( :database_dir => settings.database_dir )
run SequenceServer
