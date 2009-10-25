require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'activerecord'

require 'config/setup.rb'
require 'lib/generators'

configure :local, :development do
  dbconfig = YAML.load(File.read('config/database.yml'))
  ActiveRecord::Base.establish_connection dbconfig[:development.to_s]
end

configure :production, :test do
  dbconfig = YAML.load(File.read('config/database.yml'))
  ActiveRecord::Base.establish_connection dbconfig[options[:production.to_s]]
end

get '/' do
  discipline_name = "VFS - Vertical Formation Skydiving"
  discipline = Discipline.all(:conditions => {:title => discipline_name }).first
  moves = discipline.moves.map { |m| Generators::SkydiveMove.new(m.points, m.move_type, m.shortname) }
  generator = Generators::DiveGenerator.new(discipline_name, discipline.min_points_per_round, moves)
  
  shortestPath = generator.getShortestPath

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

get '/css/*.css' do
  content_type 'text/css', :charset => 'utf-8'
  
  sass :'css/master'
end
