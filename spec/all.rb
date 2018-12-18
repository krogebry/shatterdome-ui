# -*- mode: ruby -*-
require 'json'
require 'mongo'
require 'sinatra'
require 'easy_breadcrumbs'
require 'rack/session/dalli'
require 'rack-flash'
require 'rack/test'

require 'simplecov'
SimpleCov.start

require 'shatterdome/shatterdome'
require 'shatterdome-worker/worker'

$LOAD_PATH.push('lib') if File.path(__FILE__).match(/\./)

WEB_ROOT = File.absolute_path(File.join(File.path(__FILE__), '..', '..' ))

MEMC_HOST = ENV['MEMC_HOST'] || 'localhost'
MEMC_PORT = ENV['MEMC_PORT'] || 11211

options = { :namespace => 'dev', :compress => false }
CACHE = Shatterdome::Memcache.new( "#{MEMC_HOST}:#{MEMC_PORT}" , options)

DB_HOST = ENV['DB_HOST'] || 'localhost'
DB_PORT = ENV['DB_PORT'] || 27017

Mongo::Logger.logger.level = ::Logger::FATAL
DB = Mongo::Client.new(["#{DB_HOST}:#{DB_PORT}"], database: 'shatterdome-ui')

LOG = Logger.new(STDOUT)
LOG.level = Logger::INFO

set :bind, '0.0.0.0'
set :views, File.join(WEB_ROOT, 'views')
set :public_folder, File.join(WEB_ROOT, '/static')

ENV_NAME = ENV['ENV_NAME'] || 'dev'

configure do
  use Rack::Session::Cookie, secret: "IdoHaveANeatSecret"
  use Rack::Session::Dalli,
      namespace: format('%s.sessions', ENV_NAME),
      cache: Dalli::Client.new(format('%s:%s', MEMC_HOST, MEMC_PORT))

  use Rack::Flash
end

helpers Sinatra::EasyBreadcrumbs

require 'shatterdome/stack'

require "shatterdome-ui/version"
require "#{WEB_ROOT}/routes/api.rb"
require "#{WEB_ROOT}/routes/main.rb"
require "#{WEB_ROOT}/routes/auth.rb"
require "#{WEB_ROOT}/routes/stack.rb"
require "#{WEB_ROOT}/routes/launch_config.rb"

require './spec/main.rb'
require './spec/auth.rb'
require './spec/api.rb'
require './spec/stacks.rb'
require './spec/launch_config.rb'
