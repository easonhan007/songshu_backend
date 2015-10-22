require 'json'
require 'sinatra'
require 'data_mapper'
require 'dm-migrations'
require 'rack/cors'

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
  #DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/development.db")
  DataMapper.setup(:default, "postgres://eason@localhost/songshu")
end

configure :production do
end

require './models/init'
require './routes/init'

DataMapper.finalize

