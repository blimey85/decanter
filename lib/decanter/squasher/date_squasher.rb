module Decanter
  module Squasher
    class DateSquasher < Base
      squasher do |name, inputs, options|
        Date.new(inputs[:year], inputs[:month], inputs[:day])
      end
    end
  end
end
