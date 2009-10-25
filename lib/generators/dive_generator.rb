module Generators
  class DiveGenerator
    attr_reader :discipline, :movePool, :minPointsPerRound

    def initialize(discipline, minPointsPerRound, moves)
      @movePool = RandomHash[*moves.map { |move| [move.symbol, move]}.flatten]
      @minPointsPerRound = minPointsPerRound
      @discipline = discipline
    end

    def checkValidSetup
      raise "There are no moves in the Dive Pool" if @movePool.empty?
      raise "There are less move points in the Dive Pool than the minimum points per round" unless @movePool.values.inject(0) { |sum, move| sum + move.points } > @minPointsPerRound
      raise "The minimum points per round is lower than some of the points for the moves.  The minimum must be at least equal to the highest scoring move." unless @minPointsPerRound > @movePool.values.map { |move| move.points }.max
    end

    # get a list of random draws
    # if singleDrawPool is true then all moves are pulled from a "pool" until all moves are used up
    # if singleDrawPool is fale then each dive is completely random
    def getRandomDives(numberDives, singleDrawPool = false)
        checkValidSetup

        sequenceOfDives = DiveSequence.new
        divePool = RandomArray.new

        while (sequenceOfDives.length < numberDives)
          dive = Dive.new
          points = 0

          while points < @minPointsPerRound
            divePool.replace(@movePool.values) unless
              ((!divePool.empty?) and singleDrawPool) or
              ((points > 0) and !singleDrawPool)

            move = divePool.random
            divePool.delete(move)

            points += move.points
            dive.push(move)
          end

          sequenceOfDives.push(dive)
        end

        return sequenceOfDives
    end

    # get the least number of dives possible to do every single move to every other move
    def getShortestPath
      checkValidSetup

      sequenceOfDives = DiveSequence.new

      move_pairs =
        @movePool.values.map { |a| @movePool.values.map { |b| [a, b] } }. # make some arrays of move pairs
        inject([]) { |result, move_pairs| result.concat(move_pairs) }.    # concatenate those into a single array of move pairs
        reject { |a, b| a == b }                                          # throw away pairs of the same move

      lastMove = move_pairs[rand(move_pairs.length)].first
      currentDive = Dive.new(lastMove)

      while !move_pairs.empty?
        currentDivePoints = lastMove.points unless currentDive.length > 1

        nextMove =
          if !(next_moves = move_pairs.select { |a, b| a == lastMove }.map { |a, b| b } - currentDive).empty?
            # standard random call for next move when there are loads of moves available
            next_moves[rand(next_moves.length)]
          elsif !(next_moves = move_pairs.map { |a, b| a } - currentDive).empty?
            # nothing left in last permutation, just get a new starting position
            next_moves[rand(next_moves.length)]
          else
            # just pull anything from the move pool, nothing left at all to use!
            @movePool[@movePool.random_excluding(currentDive.collect {|mv| mv.symbol})]
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

          lastMove = move_pairs[rand(move_pairs.length)].first unless move_pairs.empty?
          currentDive = Dive.new(lastMove)
        end
      end
      
      sequenceOfDives
    end
  end
end
