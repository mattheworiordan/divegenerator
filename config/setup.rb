require 'rio'

# Iterate through any files in the models folder and require them 
files = (rio(rio(__FILE__).dirname)/".."/"models")["*.rb"].each do |file|
  require file.realpath.to_s
end

# Set up standard database connections
ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.colorize_logging = false

