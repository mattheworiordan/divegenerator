require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'generators'

get '/' do
  diveGenerator = Generators::VFSDiveGenerator.new
  # diveGenerator = Generators::FourWayDiveGenerator.new
  # diveGenerator = Generators::FreeflyDiveGenerator.new
  shortestPath = diveGenerator.getShortestPath

  @dives = shortestPath.to_s.gsub(/\n/,"<br>")
  
  haml :index
  
  # puts("\n\n
  # Summary of moves used
  # ---------------------")
  # puts(shortestPath.analyze)
  # 
  # puts("\n\n
  # Quick random draw
  # ---------------------")
  # puts(diveGenerator.getRandomDives(5, true).to_s)
end

get '/css/stylesheet.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end
