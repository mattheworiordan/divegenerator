require 'rubygems'
require 'sinatra'
require 'haml'
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

