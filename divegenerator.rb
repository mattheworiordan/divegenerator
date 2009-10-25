require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'activerecord'
require 'json'
 
require 'config/setup.rb'
require 'lib/generators'


configure :local, :development do
  dbconfig = YAML.load(File.read('config/database.yml'))
  ActiveRecord::Base.establish_connection dbconfig[:development.to_s]
end

configure :production, :test do
  dbconfig = YAML.load(File.read('config/database.yml'))
  ActiveRecord::Base.establish_connection dbconfig[:production.to_s]
end

helpers do 
  def get_selected_form_fields
    vals = params["post"] ? params["post"] : {}
    @selected_discipline = vals["discipline"]
    @selected_sequence = vals["sequence"]
    @selected_jumps = vals["jumps"]
    @selected_jumps ||= "all"
  end
end

get '/' do
  get_selected_form_fields
  @disciplines = Discipline.all(:order => "title ASC")
  haml :index
end
  
get '/shortest_path.*' do
  @content_type = :html
  case params["splat"][0]
    when "json" then @content_type = :json
    when "csv" then @content_type = :csv
  end
  content_type @content_type
  
  result = nil
  
  result = { :success => false, :message => "Parameter's missing" } unless params["post"] 
  if result.nil? 
    get_selected_form_fields
    
    disciplinedata = Discipline.all(:conditions => {:title => @selected_discipline }).first
    result = { :success => false, :message => "Discipline '#{@selected_discipline}' not found" } unless disciplinedata
    result ||= { :success => false, :message => "Number of jumps missing or invalid" } unless (@selected_sequence =~ /^shortest/) || ((@selected_jumps =~ /[\d+]/) && !(@selected_sequence =~ /^shortest/))
    
    if result.nil? 
      moves = disciplinedata.moves.map { |m| Generators::SkydiveMove.new(m.points, m.move_type, m.shortname) }
      generator = Generators::DiveGenerator.new(@selected_discipline, disciplinedata.min_points_per_round, moves)
      
      if (@selected_sequence =~ /^shortest/) then
        result ||= { :success => true, :data => generator.getShortestPath, :moves => moves}
      else
        result ||= { :success => true, :data => generator.getRandomDives(@selected_jumps.to_i, true), :moves => moves}
      end
    end
  end
  

  
  case @content_type
    when :json then 
      result.to_json; 
      mime :json, "application/json"
    when :csv then 
      result[:success] ? result[data].to_json : 'Error generating CSV - ' + result[:message]
      mime :csv, "text/csv"
    else result.to_json
  end
  
  # haml :index
  
  
  
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
