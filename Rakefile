port = 3099

desc "Start the app server"
task :start => :stop do
	puts "Starting the dive generator"
	require 'launchy'
	system "ruby app.rb -p #{port} > access.log 2>&1 &"
	puts "Waiting for server to start up...."
	sleep 3
	Launchy.open("http://localhost:#{port}/")
end

# code lifted from rush
def process_alive(pid)
	::Process.kill(0, pid)
	true
rescue Errno::ESRCH
	false
end

def kill_process(pid)
	::Process.kill('TERM', pid)

	5.times do
		return if !process_alive(pid)
		sleep 0.5
		::Process.kill('TERM', pid) rescue nil
	end

	::Process.kill('KILL', pid) rescue nil
rescue Errno::ESRCH
end

desc "Stop the app server"
task :stop do
  if RUBY_PLATFORM.downcase.include?('darwin') then
	  m = `lsof -i -P | grep *:#{port}`.match(/[^\s]*\s*(\d+)/)   # mac does not support netstat in the same format
	else
	  m = `netstat -lptn | grep 0.0.0.0:#{port}`.match(/LISTEN\s*(\d+)/)
	end

	if m
		pid = m[1].to_i
		puts "Killing old server #{pid}"
		kill_process(pid)
	end
end

desc "Create the database schema and populate with data"
task :"db:create" do
	require './db/create_db.rb'
end
