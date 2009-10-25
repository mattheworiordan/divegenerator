module Generators
  class DiveGenerator
    attr_reader :discipline, :movePool, :minPointsPerRound

    def initialize(discipline, minPointsPerRound, moves)
      @movePool = Hash[*moves.map { |move| [move.symbol, move]}.flatten]
      @minPointsPerRound = minPointsPerRound
      @discipline = discipline
    end

    def checkValidSetup
      raise "There are no moves in the Dive Pool" if @movePool.empty?
      raise "There are less move points in the Dive Pool than the minimum points per round" unless @movePool.values.inject(0) { |sum, move| sum + move.points } > @minPointsPerRound
      raise "The minimum points per round is lower than some of the points for the moves.  The minimum must be at least equal to the highest scoring move." unless @minPointsPerRound > @movePool.values.map { |move| move.points }.max
    end

    # get a list of random draws
    # works by creating a pool of all moves 
    def getRandomDives(max_jumps)
        checkValidSetup
        sequenceOfDives = DiveSequence.new

        allmoves = @movePool.values                                           # get the list of moves
        lastMove = allmoves[rand(allmoves.length)]
        currentDive = Dive.new(lastMove)
        currentDivePoints = lastMove.points
        
        while (sequenceOfDives.length < max_jumps)
          allmoves.delete(lastMove)                                          # move has been used, remove from moves        
          allmoves = @movePool.values if allmoves.empty?                     # run out of moves, restart
            
          allowed_moves = allmoves.reject { |move| currentDive.include?(move) }  # filter out any moves that may exist in the dive already - can happen if moves have been repopulated
          
          nextMove = allowed_moves[rand(allowed_moves.length)]

          currentDivePoints += nextMove.points
          currentDive << nextMove
          
          lastMove = nextMove
          
          if (currentDivePoints >= @minPointsPerRound)
            sequenceOfDives << currentDive
            lastMove = allmoves[rand(allmoves.length)]
            currentDive = Dive.new(lastMove)
            currentDivePoints = lastMove.points
          end
        end

        return sequenceOfDives
    end

    # get the least number of dives possible to do every single move to every other move
    def getShortestPath(max_jumps, random=true)
      checkValidSetup

      sequenceOfDives = DiveSequence.new
      
      move_pairs =
        @movePool.values.map { |a| @movePool.values.map { |b| [a, b] } }. # make some arrays of move pairs
        inject([]) { |result, move_pairs| result.concat(move_pairs) }.    # concatenate those into a single array of move pairs
        reject { |a, b| a == b }                                          # throw away pairs of the same move

      lastMove = random ? move_pairs[rand(move_pairs.length)].first : move_pairs.first.first
      currentDive = Dive.new(lastMove)
      
      while !move_pairs.empty? && ((max_jumps <= 0) || (sequenceOfDives.length < max_jumps)) # if max_jumps > 0 them limit jumps to max_jumps
        currentDivePoints = lastMove.points unless currentDive.length > 1

        nextMove =
          if !(next_moves = move_pairs.select { |a, b| a == lastMove }.map { |a, b| b } - currentDive).empty?
            # standard random call for next move when there are loads of moves available
            random ? next_moves[rand(next_moves.length)] : next_moves.first
          elsif !(next_moves = move_pairs.map { |a, b| a } - currentDive).empty?
            # nothing left in last permutation, just get a new starting position
            random ? next_moves[rand(next_moves.length)] : next_moves.first
          else
            # just pull anything from the move pool that has not been used, nothing left at all to use!
            anymovepool = @movePool.values.reject { |move| currentDive.include?(move) }
            random ? anymovepool[rand(anymovepool.length)] : anymovepool.first
          end

        currentDivePoints += nextMove.points
        currentDive << nextMove
        
        # clean up, remove the pair lastMove-nextMove
        move_pairs.delete([lastMove, nextMove])

        # puts (lastMove.points.to_s + "_" + nextMove.points.to_s + "     " + currentDivePoints.to_s + ":" + (currentDive.collect {|a| a.symbol + "-"}).to_s)

        if (currentDivePoints < @minPointsPerRound)
          lastMove = nextMove
        else
          # remember that a sequence such as ABC also has the pair CA in it because ABC is ABCABCABC... delete movePermutation CA
          move_pairs.delete([currentDive.first, currentDive.last])

          sequenceOfDives << currentDive

          lastMove = (random ? move_pairs[rand(move_pairs.length)].first : move_pairs.first.first) unless move_pairs.empty?
          currentDive = Dive.new(lastMove)
        end
      end
      
      sequenceOfDives
    end
  end
end
