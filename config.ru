require 'bundler'
Bundler.require

require_relative 'db/connection'
require_relative 'models/model'
require_relative 'models/distributor'
require_relative 'models/brand'

require './app'
run Sinatra::Application
