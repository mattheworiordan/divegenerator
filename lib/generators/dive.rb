module Generators
  class Dive < Array
    def initialize(firstDive = nil)
      super(0)
      push(firstDive) if firstDive
    end

    def to_s
      map { |v| v.symbol }.join('-')
    end
  end
end
