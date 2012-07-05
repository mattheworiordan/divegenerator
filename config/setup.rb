# Iterate through any files in the models folder and require them
files = Dir.glob('./models/*.rb').each do |file|
  require file
end

# Set up standard database connections
ActiveRecord::Base.logger = Logger.new(STDERR)

