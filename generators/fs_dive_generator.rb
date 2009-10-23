module Generators
  class FSDiveGenerator < DiveGenerator
    def initialize
      super
      ('A'..'Q').each { |v| @movePool[v] = SkydiveMove.new(1, DIVE_RANDOM, v) }
      ('1'..'22').each { |v| @movePool[v] = SkydiveMove.new(2, DIVE_BLOCK, v) }
      @minPointsPerRound = 5
    end
  end
end
