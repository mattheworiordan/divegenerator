module Generators
  class DiveSequence < Array
    def to_s
      (1..length).zip(self).map { |index, dive| "#{index}. #{dive}" }.join("\n")
    end

    def analyze
      moves = Hash.new
      flatten.map { |move| move.symbol }.each do |symbol|
        moves[symbol] ||= 0
        moves[symbol] += 1
      end

      moves.sort.map { |move, count| "#{move} is used #{count} times" }.join("\n")
    end
  end
end
