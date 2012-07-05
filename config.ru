require 'rubygems'
require 'bundler'

Bundler.require

require 'logger'

require './app'
run Sinatra::Application