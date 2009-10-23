module Generators
  module Random
    def keys_excluding (ignoreValues = {})
      permittedValues = Array.new
      thisObjectValues = (self.kind_of?(Array) ? self : self.keys)

      case ignoreValues
      when Hash
        thisObjectValues.each { |key| permittedValues.push(key) unless (ignoreValues[key]) }
      when Array
        thisObjectValues.each { |key| permittedValues.push(key) unless (ignoreValues.include?(key)) }
      else
        raise ArgumentError, "Array or Collection must be passed as the ignoreValues parameter"
      end

      return permittedValues
    end

    def random_excluding (ignoreValues = {})
      permittedValues = keys_excluding(ignoreValues)
      raise ArgumentError, "There are zero values to return", caller if permittedValues.empty?
      return permittedValues[rand(permittedValues.length)]
    end

    def random
      random_excluding
    end
  end
end
