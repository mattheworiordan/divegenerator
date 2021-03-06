require './config/setup.rb'
require './lib/generators/generators.rb'

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
    @selected_sequence = vals["sequence"] ? vals["sequence"] : nil # set shortest random to default if no other value exists
    @selected_jumps = vals["jumps"] =~ /\d+/ ? vals["jumps"] : nil
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

    disciplinedata = Discipline.all(:conditions => {:title => @selected_discipline }, :order => "title ASC").first
    result = { :success => false, :message => "Discipline '#{@selected_discipline}' not found" } unless disciplinedata
    result ||= { :success => false, :message => "Number of jumps missing or invalid" } unless ((@selected_sequence =~ /^shortest/) || !@selected_jumps.nil? && !(@selected_sequence =~ /^shortest/))

    if result.nil?
      moves = disciplinedata.moves.map { |m| Generators::SkydiveMove.new(m.points, m.move_type, m.shortname) }
      generator = Generators::DiveGenerator.new(@selected_discipline, disciplinedata.min_points_per_round, moves)

      if (@selected_sequence =~ /^shortest/) then
        result ||= { :success => true, :data => generator.getShortestPath(@selected_jumps.to_i, (@selected_sequence =~ /random/ ? true : false)), :moves => moves}
      else
        result ||= { :success => true, :data => generator.getRandomDives(@selected_jumps.to_i), :moves => moves}
      end
    end
  end

  case @content_type
    when :json then
      mime_type 'application/json'
      result.to_json
    when :csv then
      mime_type 'text/csv'
      result[:success] ? "Dive\n" + result[:data].map { |move| "'" << (move.map { |mv| mv.symbol }.join('-')) << "'" }.join("\n") : 'Error generating CSV - ' + result[:message]
    else result[:success] ? result[:data].map { |move| move.map { |mv| mv.symbol }.join('-') }.join('<br>') : '<h1>Error generating HTML - ' + result[:message] + '</h1>'
  end
end

get '/css/*.css' do
  content_type 'text/css', :charset => 'utf-8'

  scss :'css/master'
end

get '/docs/2012_CR_VFS.pdf' do
  content_type 'application/pdf', :charset => 'utf-8'
  mime_type 'application/pdf'
  File.open('./docs/2012_CR_VFS.pdf').read
end
