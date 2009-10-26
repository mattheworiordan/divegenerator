require File.dirname(__FILE__) + '/../lib/generators/generators.rb'

describe Generators::DiveGenerator do
	before do
	  @moves = ('1'..'5').map { |v| Generators::SkydiveMove.new(1, Generators::DIVE_RANDOM, v) }
	  @moves.concat (('A'..'E').map { |v| Generators::SkydiveMove.new(2, Generators::DIVE_BLOCK, v) })
		@generator = Generators::DiveGenerator.new("Test Discipline", 4, @moves)
	end

	it "has 10 moves in total" do
		@moves.length.should == 10
	end
	
  it "generates 10 random dives when asked for 10 random dives" do
    @generator.getRandomDives(10).length.should == 10
  end
	
	it "should not provide any duplicate moves when asked for 3 random dives from a pool of 10" do
	  @moves = Hash.new
	  (@generator.getRandomDives(3)).each { |dive| dive.each { |move| @moves[move.symbol] ||= 0; @moves[move.symbol] += 1; } }
		@moves.values.max.should == 1
	end
	
	it "should return a dive plan of at least 20 jumps when asked to do all move combinations in random order" do
	  @generator.getShortestPath(0, true).length.should be > 20
	end
end
