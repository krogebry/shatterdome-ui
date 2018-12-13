#!/usr/bin/env ruby
require 'json'
require 'sinatra'
require 'easy_breadcrumbs'
require 'rack/session/dalli'
require 'rack-flash'

require 'shatterdome/shatterdome'

$LOAD_PATH.push('lib') if File.path(__FILE__).match(/\./)

# if ENV.has_key?('WEB_ROOT')
  # WEB_ROOT = File.absolute_path(ENV['WEB_ROOT'])
# else
WEB_ROOT = File.absolute_path(File.join(File.path(__FILE__), '..', '..' ))
# end

MEMC_HOST = ENV['MEMC_HOST'] || 'localhost'
MEMC_PORT = ENV['MEMC_PORT'] || 11211

options = { :namespace => 'dev', :compress => false }
CACHE = Shatterdome::Memcache.new( "#{MEMC_HOST}:#{MEMC_PORT}" , options)

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

# require 'shatterdome/stack.rb'
# require 'shatterdome/worker.rb'

require "shatterdome-ui/version"
require "#{WEB_ROOT}/routes/main.rb"

