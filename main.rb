require 'json'
require 'sinatra'
require 'data_mapper'
require 'dm-migrations'
require 'rack/cors'
require 'date'
require 'digest/md5'

use Rack::MethodOverride 
use Rack::Cors do
  allow do 
    origins 'localhost:4567', 'localhost:8000'
    resource '*', 
      headers: :any,
      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'],
      methods: [:get, :post, :options, :delete, :put]
  end
end

configure :development do
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/development.db")
  #DataMapper.setup(:default, "postgres://eason@localhost/songshu")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

# see https://github.com/heroku/devcenter-client-caching-sinatra-example
# for more detail
before '/api/*' do 
  cache_control :public, :must_revalidate, max_age: 86400 
  last_modified Date.today
end

require './models/init'
require './routes/init'

DataMapper.finalize


