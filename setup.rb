require "roda"
require 'pry'
require 'sequel'
require_relative 'queued/atomic_worker.rb'
require_relative 'queued/donation_processor.rb'

DB = Sequel.sqlite # memory database, requires sqlite3

DB.create_table :charities do
  primary_key :id
  String :name
  Integer :donated_dollars
end

charities = DB[:charities] # Create a dataset


# a sample charity
charities.insert(name: 'You Favorite Charity', donated_dollars: 0)

# Print out the number of charities
puts "Great! Your DB is set up with #{charities.count} charities!"

# just putting this here so we don't have to drop down to the dataset level for
# simple stuff. it will make the roda app more readable
class Charity < Sequel::Model
end
