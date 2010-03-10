dives_done_file = "dives-done.txt"
dive_regex = /(?:[a-i]+|[0-9]+)/i
move_average_per_dive = 15

dives_done_file = File.join(File.dirname(__FILE__), dives_done_file)
raise "Dives done file is missing.  Path = #{dives_done_file}" if (!File.exists?(dives_done_file))

file = File.new(dives_done_file, "r")

dives = []
while (dive_string = file.gets)
  dive_string = dive_string.gsub(/\s*(drills?|\'s)\s*/i, "")     # clear out drills or 's in the text
  moves = dive_string.scan(dive_regex).map { |move| move.upcase }
  if (moves.respond_to?(:length) && (moves.length > 0) )
    moves_averaged = []
    moves_completed = 0
    while (moves_completed < move_average_per_dive)
      move = moves[moves_averaged.length % (moves.length)] 
      moves_averaged << move
      moves_completed += move.match(/[0-9]+/) ? 2 : 1 # allow for blocks to take up two moves
    end
    dives << moves_averaged
  end
end

moves = {}
dives.flatten.each do |move| 
  moves[move] = moves.has_key?(move) ? moves[move] + 1 : 1
end 

puts "Moves by type"
moves.sort.each { |move, move_count| puts "#{move} - #{move_count} time#{move_count == 1 ? '' : 's'}"}

puts "\n\nMoves by amount of times done"
moves.sort { |a,b| a[1] <=> b[1] }.each { |move, move_count| puts "#{move} - #{move_count} time#{move_count == 1 ? '' : 's'}"}


