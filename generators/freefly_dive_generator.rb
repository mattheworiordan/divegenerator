module Generators
  class FreeflyDiveGenerator < DiveGenerator
    def initialize
      super
      ('1'..'10').each { |v| @movePool[v] = SkydiveMove.new(1, DIVE_RANDOM, v) }
      @minPointsPerRound = 5
    end
  end
end
