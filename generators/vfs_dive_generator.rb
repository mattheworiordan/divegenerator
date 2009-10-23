module Generators
  class VFSDiveGenerator < DiveGenerator
    def initialize
      super
      ('1'..'14').each { |v| @movePool[v] = SkydiveMove.new(2, DIVE_BLOCK, v) }
      ('A'..'L').each { |v| @movePool[v] = SkydiveMove.new(1, DIVE_RANDOM, v) }
      @minPointsPerRound = 4
    end
  end
end
