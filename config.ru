require 'bundler'
Bundler.require

require_relative 'db/connection'
require_relative 'models/model'
require_relative 'models/distributor'
require_relative 'models/brand'

I18n.load_path << Dir[File.expand_path('config/locales') + '/*.yml']
I18n.default_locale = :en # (note that `en` is already the default!)

require './app'
enable :sessions
run Sinatra::Application
