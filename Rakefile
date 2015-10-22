require 'dm-migrations'

desc 'List all the routes' 
task :routes do
  puts `grep '^[get|post|put|delete].*do$' routes/*.rb | sed 's/ do$//'`
end

desc 'migrates the db'
task :migrate do
  require './main'
  DataMapper.auto_migrate!
end

desc 'upgrates the db'
task :upgrate do
  require './main'
  DataMapper.auto_migrate!
end

desc 'get post list' 
task :get_posts do
  require './main'
  require './spider/posts'
  ArticlePersistent.new.fetch_all_posts
end